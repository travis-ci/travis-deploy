require 'spec_helper'

describe Travis::Deploy::Config do
  let(:shell)  { Mock::Shell.new }
  let(:config) { "staging:\n  foo: bar" }

  before :each do
    Travis::Deploy::Config.any_instance.stub(:clean? => true)
    Travis::Deploy::Config.any_instance.stub(:run)
    Travis::Keychain.any_instance.stub(:source => config)
    File.stub(:open)
  end

  describe 'sync' do
    it 'fetches the config from the keychain' do
      command = Travis::Deploy::Config.new(shell, 'staging', {})
      command.send(:keychain).should_receive(:source).and_return(config)
      command.invoke
    end

    it 'writes the config to the local config file' do
      command = Travis::Deploy::Config.new(shell, 'staging', {})
      File.should_receive(:open).with { |path, mode| path =~ %r(config/travis.yml) }
      command.invoke
    end

    it 'pushes the config to the given heroku remote' do
      command = Travis::Deploy::Config.new(shell, 'staging', {})
      command.should_receive(:run).with { |cmd, options| cmd =~ /heroku config:add travis_config=.* -r staging/m }
      command.invoke
    end
  end
end
