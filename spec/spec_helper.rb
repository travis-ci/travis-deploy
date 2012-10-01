ENV['RAILS_ENV'] = ENV['ENV'] = 'test'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start
end

require 'rspec/mocks'

RSpec.configure do |c|
  c.mock_with :mocha
  c.before(:each) { Time.now.utc.tap { | now| Time.stubs(:now).returns(now) } }
end

require 'travis/cli'
require 'mocha'
require 'vcr'

module Mock
  class Shell
    def messages
      @messages ||= []
    end

    def say(*args)
      messages << args
    end
    alias :error :say
  end
end

module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out.string
  ensure
    $stdout = STDOUT
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :fakeweb
end