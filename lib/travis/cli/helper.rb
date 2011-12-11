module Travis
  class Cli
    module Helper
      protected

        def run(cmd, options = {})
          cmd = cmd.strip
          puts "$ #{options[:echo] || cmd}" unless options[:echo].is_a?(FalseClass)
          system cmd
        end

        def say(message)
          shell.say(message, :green)
        end

        def error(message)
          message = shell.set_color(message, :red)
          shell.error(message)
          exit 1
        end
    end
  end
end
