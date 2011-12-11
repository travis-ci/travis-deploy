require 'thor'
require 'shellwords'
require 'fileutils'
require 'yaml'

module Travis
  class Cli
    class Config
      include Helper

      attr_reader :shell, :remote, :options

      def initialize(shell, remote, options)
        @remote = remote
        @options = options
        @shell = shell
      end

      def invoke
        store
        push
        restart if restart?
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
          @config ||= keychain.fetch
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
          config = Shellwords.escape(YAML.dump(YAML.load(self.config)[remote]))
          run "heroku config:add travis_config=#{config} -r #{remote}", :echo => "heroku config:add travis_config=... -r #{app}"
        end

        def restart
          say 'Restarting the app ...'
          run "heroku restart -r #{remote}"
        end

        def backup
          say 'Backing up the old config file ...'
          run "cp #{filename} #{filename}.backup"
        end

        def restart?
          !!options['restart']
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
