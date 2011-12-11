require 'spec_helper'

describe Travis::Cli::Deploy do
  let(:shell)  { Mock::Shell.new }

  before :each do
    $stdout = StringIO.new
    Travis::Cli::Deploy.any_instance.stubs(:clean?).returns(true)
    Travis::Cli::Deploy.any_instance.stubs(:branch).returns('master')
    File.stubs(:open)
  end

  after :each do
    $stdout = STDOUT
  end

  describe 'with a clean working directory' do
    describe 'given remote "production"' do
      let(:command) { Travis::Cli::Deploy.new(shell, 'production', {}) }

      before :each do
        command.stubs(:system)
      end

      it 'switches to the production branch' do
        command.expects(:system).with('git checkout production')
        command.invoke
      end

      it 'resets the production branch to the current branch' do
        command.expects(:system).with('git reset --hard master')
        command.invoke
      end

      it 'pushes the production branch to origin' do
        command.expects(:system).with('git push origin production')
        command.invoke
      end

      it 'switches back to the previous branch' do
        command.expects(:system).with('git checkout master')
        command.invoke
      end

      it 'tags the current commit ' do
        command.expects(:system).with { |cmd| cmd =~ /git tag -a 'deploy .*' -m 'deploy .*'/ }
        command.invoke
      end

      it 'pushes the tag to origin' do
        command.expects(:system).with('git push --tags')
        command.invoke
      end

      it 'pushes to the given remote' do
        command.expects(:system).with('git push production HEAD:master')
        command.invoke
      end
    end

    describe 'given the remote "staging"' do
      let(:command) { Travis::Cli::Deploy.new(shell, 'staging', {}) }

      before :each do
        command.stubs(:system)
      end

      it 'does not switch to the production branch' do
        command.expects(:system).with('git checkout production').never
        command.invoke
      end

      it 'does not tag the current commit if the given remote is "staging"' do
        command.expects(:system).with { |cmd| cmd =~ /git tag -a 'deploy .*' -m 'deploy .*'/ }.never
        command.invoke
      end

      it 'pushes to the given remote' do
        command.expects(:system).with('git push staging HEAD:master')
        command.invoke
      end
    end

    it 'migrates the database if --migrate is given' do
      command = Travis::Cli::Deploy.new(shell, 'production', 'migrate' => true)
      command.stubs(:system)
      command.expects(:system).with('heroku run rake db:migrate -r production')
      command.invoke
    end

    it 'configures the application if --configure is given' do
      command = Travis::Cli::Deploy.new(shell, 'production', 'configure' => true)
      command.stubs(:system)
      command.expects(:configure)
      command.invoke
    end
  end

  describe 'with a dirty working directory' do
    before :each do
    end

    it 'outputs an error message' do
      command = Travis::Cli::Deploy.new(shell, 'production', {})
      command.stubs(:clean?).returns(false)
      command.expects(:error).with('There are unstaged changes.')
      command.invoke
    end
  end
end
