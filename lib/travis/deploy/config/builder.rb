class Travis::Deploy::Config
  class Builder
    attr_reader :config, :env, :keychain

    def initialize(keychain, env)
      @keychain = keychain
      @config = YAML.load(keychain.source)
      @env = env
    end

    def build
      includes = []

      includes << config.delete('includes') if config['includes']
      includes << env_config.delete('includes') if env_config['includes']

      includes.flatten!

      result = env_config
      includes.each do |name|
        include_config = keychain.includes(name)
        result.merge! include_config['all'] || {}
        result.merge! include_config[env] || {}
      end

      result
    end

    def env_config
      config.fetch env, {}
    end
  end
end
