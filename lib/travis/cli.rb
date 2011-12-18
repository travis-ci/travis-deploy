require 'thor'

$stdout.sync = true

module Travis
  autoload :Keychain, 'travis/keychain'

  class Cli < Thor
    autoload :Config, 'travis/cli/config'
    autoload :Deploy, 'travis/cli/deploy'
    autoload :Helper, 'travis/cli/helper'

    namespace 'travis'

    desc 'config', 'Sync config between keychain, app and local working directory'
    method_option :backup,  :aliases => '-b', :type => :boolean, :default => false

    def config(remote)
      Config.new(shell, remote, options).invoke
    end

    desc 'deploy', 'Deploy to the given remote'
    method_option :migrate, :aliases => '-m', :type => :boolean, :default => false
    method_option :configure, :aliases => '-c', :type => :boolean, :default => false

    def deploy(remote)
      Deploy.new(shell, remote, options).invoke
    end
  end
end
