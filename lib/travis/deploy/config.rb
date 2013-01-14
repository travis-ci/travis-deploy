require 'shellwords'
require 'yaml'

module Travis
  class Deploy
    class Config
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

      protected

        def app
          @app ||= begin
            app = File.basename(Dir.pwd).gsub('travis-', '')
            app = 'web' if app == 'ci'
            app
          end
        end

        def config
          @config ||= source || keychain.fetch
        end

        def source
          File.read(options['source']) if options['source']
        end

        def keychain
          @keychain ||= Keychain.new(app, shell)
        end

        def store
          backup if backup?
          File.open(filename, 'w+') { |f| f.write(config) }
        end

        def push
          say 'Configuring the app ...'
          config = Shellwords.escape(YAML.dump(YAML.load(self.config)[env]))
          run "heroku config:add travis_config=#{config} -r #{remote}", :echo => "heroku config:add travis_config=... -r #{remote}"
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
