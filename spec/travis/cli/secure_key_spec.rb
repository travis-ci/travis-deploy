require 'spec_helper'

describe Travis::Trvs::SecureKey do
  describe 'key' do
    before do
      # Travis API requests redirect to HTTPS
      stub_request(:any, %r(^http://secure.travis-ci\.org/)).to_return do |request|
        {
          :body => '',
          :status => [301, 'Moved Permanently'],
          :headers => {
            'Location' => request.uri.to_s.sub(/^http/, 'https')
          }
        }
      end
    end

    it 'allows to pass host' do
      slug = 'travis-ci/travis-cli'
      public_key = <<-KEY
-----BEGIN RSA PUBLIC KEY-----
MIGJAoGBAON8DcLBjBwkspYPtHvdjoOYwjsUJOh5Otr+TEOlfvUgDjc/kGRjP6ku
THug6JpLU0GlRqOr4u9sFuJCKlDjCJV+2vWzP4e+3zrP9hZGdQUcbG2fhSOBn2Wv
9wFMn+WFgJ3fEsvIb5yzNsRnH3mMe1MZkTPBZIrt+6M1lM1yOZQpAgMBAAE=
-----END RSA PUBLIC KEY-----
KEY

      stub_request(:get, "https://foo.travis-ci.org/repos/#{slug}/key").to_return(
        {
          :body => %({"key":#{MultiJson.dump(public_key)}}),
          :status => [200, 'OK']
        }
      )

      secure_key = Travis::Trvs::SecureKey.new(slug, 'foo.travis-ci.org')

      expect{
        secure_key.key
      }.to_not raise_error(Travis::Trvs::SecureKey::FetchKeyError)

      secure_key.key.to_pem.should == OpenSSL::PKey::RSA.new(public_key).to_pem
    end

    it 'fetches the public key for a valid slug' do
      slug = 'travis-ci/travis-cli'
      public_key = <<-KEY
-----BEGIN RSA PUBLIC KEY-----
MIGJAoGBAON8DcLBjBwkspYPtHvdjoOYwjsUJOh5Otr+TEOlfvUgDjc/kGRjP6ku
THug6JpLU0GlRqOr4u9sFuJCKlDjCJV+2vWzP4e+3zrP9hZGdQUcbG2fhSOBn2Wv
9wFMn+WFgJ3fEsvIb5yzNsRnH3mMe1MZkTPBZIrt+6M1lM1yOZQpAgMBAAE=
-----END RSA PUBLIC KEY-----
KEY

      stub_request(:get, "https://api.travis-ci.org/repos/#{slug}/key").to_return(
        {
          :body => %({"key":#{MultiJson.dump(public_key)}}),
          :status => [200, 'OK']
        }
      ).with(:headers => {'Accept' => 'application/vnd.travis-ci.2+json' })

      secure_key = Travis::Trvs::SecureKey.new(slug)

      expect{
        secure_key.key
      }.to_not raise_error(Travis::Trvs::SecureKey::FetchKeyError)

      secure_key.key.to_pem.should == OpenSSL::PKey::RSA.new(public_key).to_pem
    end
  end
end
