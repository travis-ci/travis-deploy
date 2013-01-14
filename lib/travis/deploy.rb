require 'thor'

$stdout.sync = true

module Travis
  autoload :Keychain, 'travis/keychain'

  class Deploy < Thor
    autoload :Config,    'travis/deploy/config'
    autoload :Deploy,    'travis/deploy/deploy'
    autoload :Helper,    'travis/deploy/helper'
    autoload :SecureKey, 'travis/deploy/secure_key'

    namespace 'travis'

    desc 'config', 'Sync config between keychain, app and local working directory'
    method_option :env,    :aliases => '-e', :type => :string
    method_option :source, :aliases => '-s', :type => :string
    method_option :backup, :aliases => '-b', :type => :boolean, :default => false

    def config(remote)
      Config.new(shell, remote, options).invoke
    end

    desc 'deploy', 'Deploy to the given remote'
    method_option :migrate, :aliases => '-m', :type => :boolean, :default => false
    method_option :configure, :aliases => '-c', :type => :boolean, :default => false

    def deploy(remote)
      Deploy.new(shell, remote, options).invoke
    end

    desc 'encrypt <slug> <secret>', 'Encrypt string for a repository'
    method_option :host, :aliases => '-h', :type => :string

    def encrypt(slug, secret)
      puts "\nAbout to encrypt '#{secret}' for '#{slug}'\n\n"

      encrypted = nil
      begin
        encrypted = SecureKey.new(slug, options[:host]).encrypt(secret)
      rescue SecureKey::FetchKeyError
        abort 'There was an error while fetching public key, please check if you entered correct slug'
      end

      puts "Please add the following to your .travis.yml file:"
      puts ""
      puts "  secure: \"#{Base64.encode64(encrypted).strip.gsub("\n", "\\n")}\""
      puts ""
    end
  end
end
