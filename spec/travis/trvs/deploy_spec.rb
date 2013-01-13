require 'spec_helper'

describe Travis::Trvs::Deploy do
  let(:shell)  { Mock::Shell.new }

  before :each do
    $stdout = StringIO.new
    Travis::Trvs::Deploy.any_instance.stub(:clean? => true)
    Travis::Trvs::Deploy.any_instance.stub(:branch => 'master')
    File.stub(:open)
  end

  after :each do
    $stdout = STDOUT
  end

  describe 'with a clean working directory' do
    describe 'given remote "production"' do
      let(:command) { Travis::Trvs::Deploy.new(shell, 'production', {}) }

      before :each do
        command.stub(:system => true)
      end

      it 'switches to the production branch' do
        command.should_receive(:system).with('git checkout production').and_return(true)
        command.invoke
      end

      it 'resets the production branch to the current branch' do
        command.should_receive(:system).with('git reset --hard master').and_return(true)
        command.invoke
      end

      it 'pushes the production branch to origin' do
        command.should_receive(:system).with('git push origin production -f').and_return(true)
        command.invoke
      end

      it 'switches back to the previous branch' do
        command.should_receive(:system).with('git checkout master').and_return(true)
        command.invoke
      end

      it 'tags the current commit ' do
        command.should_receive(:system).with { |cmd| cmd =~ /git tag -a 'deploy.*' -m 'deploy.*'/ }.and_return(true)
        command.invoke
      end

      it 'pushes the tag to origin' do
        command.should_receive(:system).with('git push --tags').and_return(true)
        command.invoke
      end

      it 'pushes to the given remote' do
        command.should_receive(:system).with('git push production HEAD:master -f').and_return(true)
        command.invoke
      end
    end

    describe 'given the remote "staging"' do
      let(:command) { Travis::Trvs::Deploy.new(shell, 'staging', {}) }

      before :each do
        command.stub(:system => true)
      end

      it 'does not switch to the production branch' do
        command.should_not_receive(:system).with('git checkout production')
        command.invoke
      end

      it 'does not tag the current commit if the given remote is "staging"' do
        command.should_not_receive(:system).with { |cmd| cmd =~ /git tag -a 'deploy .*' -m 'deploy .*'/ }
        command.invoke
      end

      it 'pushes to the given remote' do
        command.should_receive(:system).with('git push staging HEAD:master -f').and_return(true)
        command.invoke
      end
    end

    it 'migrates the database if --migrate is given' do
      command = Travis::Trvs::Deploy.new(shell, 'production', 'migrate' => true)
      command.stub(:system => true)
      command.should_receive(:system).with('heroku run rake db:migrate -r production').and_return(true)
      command.invoke
    end

    it 'restarts the app when the database is migrated' do
      command = Travis::Trvs::Deploy.new(shell, 'production', 'migrate' => true)
      command.stub(:system => true)
      command.should_receive(:system).with('heroku restart -r production').and_return(true)
      command.invoke
    end

    it 'configures the application if --configure is given' do
      command = Travis::Trvs::Deploy.new(shell, 'production', 'configure' => true)
      command.stub(:system => true)
      command.should_receive(:configure)
      command.invoke
    end
  end

  describe 'with a dirty working directory' do
    before :each do
    end

    it 'outputs an error message' do
      command = Travis::Trvs::Deploy.new(shell, 'production', {})
      command.stub(:clean? => false)
      command.should_receive(:error).with('There are unstaged changes.')
      command.invoke
    end
  end
end
