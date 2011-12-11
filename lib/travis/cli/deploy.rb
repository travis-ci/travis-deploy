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
          tag if remote == 'production'
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
          say "Deploying to #{remote}."
          run "git push #{remote} HEAD:master -f".strip
        end

        def tag
          with_branch('production') do |branch|
            say "Updating production branch."
            run "git reset --hard #{branch}"
            run 'git push origin production -f'

            say "Tagging #{version}."
            run "git tag -a '#{version.gsub(':', '-').gsub(' ', '.')}' -m '#{version}'"
            run 'git push --tags'
          end
        end

        def with_branch(target)
          current = branch
          run "git checkout #{target}"
          yield current
          run "git checkout #{current}"
        end

        def branch
          `git branch --no-color 2> /dev/null` =~ /\* (.*)$/ && $1
        end

        def version
          @version ||= "deploy #{Time.now.utc.strftime('%Y-%m-%d %H:%M')}"
        end

        def configure?
          !!options['configure']
        end

        def configure
          Config.new(shell, remote, :restart => false).invoke
        end

        def migrate?
          !!options['migrate']
        end

        def migrate
          say 'Running migrations'
          run "heroku run rake db:migrate -r #{remote}"
        end
    end
  end
end
