require 'spec_helper'

describe Travis::Cli::Config do
  let(:shell)  { Mock::Shell.new }
  let(:config) { "staging:\n  foo: bar" }

  before :each do
    Travis::Cli::Config.any_instance.stubs(:clean?).returns(true)
    Travis::Cli::Config.any_instance.stubs(:run)
    Travis::Keychain.any_instance.stubs(:fetch).returns(config)
    File.stubs(:open)
  end

  describe 'sync' do
    it 'fetches the config from the keychain' do
      command = Travis::Cli::Config.new(shell, 'staging', {})
      command.send(:keychain).expects(:fetch).returns(config)
      command.invoke
    end

    it 'writes the config to the local config file' do
      command = Travis::Cli::Config.new(shell, 'staging', {})
      File.expects(:open).with { |path, mode| path =~ %r(config/travis.yml) }
      command.invoke
    end

    it 'pushes the config to the given heroku remote' do
      command = Travis::Cli::Config.new(shell, 'staging', {})
      command.expects(:run).with { |cmd, options| cmd =~ /heroku config:add travis_config=.* -r staging/m }
      command.invoke
    end
  end
end
