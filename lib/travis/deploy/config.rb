require 'shellwords'
require 'yaml'

module Travis
  class Deploy
    class Config
      autoload :Builder, 'travis/deploy/config/builder'
      include Helper

      attr_reader :shell, :remote, :env, :options

      def initialize(shell, remote, options)
        @remote = remote
        @options = options
        @shell = shell
        @env = options['env'] || remote
      end

      def invoke
        store unless options['source']
        push
      end

      def pretend
        say 'Config to upload:'
        say YAML.dump(config)
      end

      protected

        def app
          @app ||= options[:app] || File.basename(Dir.pwd).gsub('travis-', '')
        end

        def config
          @config ||= source ? YAML.load(source) : Builder.new(keychain, env).build
        end

        def yaml_config
          @yaml_config ||= source || keychain.source
        end

        def source
          File.read(options['source']) if options['source']
        end

        def keychain
          @keychain ||= Keychain.new(app, shell)
        end

        def store
          backup if backup?
          File.open(filename, 'w+') { |f| f.write(yaml_config) }
        end

        def push
          say 'Configuring the app ...'
          yaml = Shellwords.escape(YAML.dump(config))
          run "heroku config:add travis_config=#{yaml} -r #{remote}", :echo => "heroku config:add travis_config=... -r #{remote}"
        end

        def backup
          say 'Backing up the old config file ...'
          run "cp #{filename} #{filename}.backup"
        end

        def backup?
          !!options['backup']
        end

        def filename
          "config/travis.yml"
        end
    end
  end
end
