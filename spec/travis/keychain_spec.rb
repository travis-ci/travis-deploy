require 'spec_helper'

describe Travis::Keychain do
  let(:shell)    { stub('shell', :say => nil, :error => nil) }
  let(:keychain) { Travis::Keychain.new('hub', shell) }

  before :each do
    keychain.stub(:system => true)
    keychain.stub(:`)
    keychain.stub(:clean? => true)
    File.stub(:read)
  end

  def fetch
    capture_stdout do
      keychain.fetch
    end
  end

  describe 'fetch' do
    it 'changes to the keychain directory' do
      Dir.should_receive(:chdir).with { |path| path =~ %r(/travis-keychain$) }
      fetch
    end

    it 'errors if the working directory is dirty' do
      keychain.stub(:clean? => false)
      keychain.should_receive(:error).with('There are unstaged changes in your travis-keychain working directory.')
      fetch
    end

    it 'pulls changes from origin' do
      keychain.should_receive(:run).with('git pull')
      fetch
    end

    it 'reads the configuration' do
      File.should_receive(:read).with { |path| path =~ %r(config/travis.hub.yml$) }
      fetch
    end
  end
end
