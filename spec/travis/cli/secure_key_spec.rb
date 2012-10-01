require 'spec_helper'

describe Travis::Cli::SecureKey do
  TRAVIS_PUBLIC_KEY =<<-eos
-----BEGIN RSA PUBLIC KEY-----
MIGJAoGBANDiAm1UJi57tMGzNjHjlEAwquanL8QhOybyL8JwWjPEZOdz/CZwXwU0
GI4o1tEWrlgUiu4OJgclvyLHLSDBJP3V1JY0bztA33HL6VCWgmHlpioFxK3px+SP
dP6Tw7EwJ3lrYeguJtz/P9jJlACAWXgHCtr+7SHdiCHVEIkbuSgtAgMBAAE=
-----END RSA PUBLIC KEY-----
eos

  describe 'fetch_key' do
    let(:pkey) { }
    it 'fetches the key from the slug' do
      OpenSSL::PKey::RSA.expects(:new).with(TRAVIS_PUBLIC_KEY)
      VCR.use_cassette('slug') do
        secure_key = Travis::Cli::SecureKey.new('travis-ci/travis-core')
        puts secure_key.key
      end
    end
  end
end
