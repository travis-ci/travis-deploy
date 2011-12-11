require 'thor'

module Travis
  class Cli
    class Deploy
      include Helper

      attr_reader :shell, :remote, :options

      def initialize(shell, remote, options)
        @remote = remote
        @options = options
        @shell = shell
      end

      def invoke
        if clean?
          tag if production?
          configure if configure?
          push
          migrate if migrate?
        else
          error 'There are unstaged changes.'
        end
      end

      protected

        attr_reader :remote

        def clean?
          `git status`.include?('working directory clean')
        end

        def push
          say "Deploying to #{remote}"
          run "git push #{remote} HEAD:master #{'-f' if force?}".strip
        end

        def tag
          say "Tagging #{version}"
          with_branch('production') do |branch|
            run "git reset --hard #{branch}"
            run 'git push origin production'
          end
          run "git tag -a 'deploy #{version}' -m 'deploy #{version}'"
          run 'git push --tags'
        end

        def with_branch(target)
          current = branch
          run "git checkout #{target}"
          yield current
          run "git checkout #{current}"
        end

        def branch
          `git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1 /'`
        end

        def version
          @version ||= "deploy #{Time.now.utc.strftime('%Y-%m-%d %H:%M')}"
        end

        def production?
          remote == 'production'
        end

        def configure?
          !!options['configure']
        end

        def configure
          Config.new(remote, shell, :restart => false)
        end

        def force?
          !!options['force']
        end

        def migrate?
          !!options['migrate']
        end

        def migrate
          run "heroku run rake db:migrate -r #{remote}"
        end
    end
  end
end
