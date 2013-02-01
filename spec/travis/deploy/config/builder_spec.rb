require 'spec_helper'

class Travis::Deploy::Config
  describe Builder do
    let(:env) { 'staging' }
    let(:config) { "staging:\n  foo: bar" }
    let(:keychain) { stub(:keychain, source: @config || config) }
    let(:builder) { Builder.new(keychain, env) }

    it 'loads config for given env' do
      builder.build.should == { 'foo' => 'bar' }
    end

    it 'includes files specified at a top level' do
      @config = YAML.dump 'includes' => ['pusher'], 'staging' => { 'foo' => 'bar' }
      pusher_config = {
        'all' => { 'bar' => 'baz', 'baz' => 'should be overwritten' },
        'staging' => { 'baz' => 'qux' },
        'development' => { 'no' => 'no' }
      }
      keychain.should_receive(:includes).with('pusher').and_return(pusher_config)

      builder.build.should == { 'foo' => 'bar', 'bar' => 'baz', 'baz' => 'qux' }
    end

    it 'includes files specified for an env' do
      @config = YAML.dump 'staging' => { 'foo' => 'bar', 'includes' => ['pusher'] },
                          'production' => { 'includes' => ['encryption'] }

      pusher_config = {
        'all' => { 'bar' => 'baz', 'baz' => 'should be overwritten' },
        'staging' => { 'baz' => 'qux' },
        'development' => { 'no' => 'no' }
      }
      keychain.should_receive(:includes).with('pusher').and_return(pusher_config)

      builder.build.should == { 'foo' => 'bar', 'bar' => 'baz', 'baz' => 'qux' }

    end
  end
end
