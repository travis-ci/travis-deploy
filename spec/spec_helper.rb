ENV['RAILS_ENV'] = ENV['ENV'] = 'test'

RSpec.configure do |c|
  c.before(:each) { Time.now.utc.tap { | now| Time.stub(:now => now) } }
end

require 'travis/cli'

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

