require 'spec_helper'

describe Travis::Cli::SecureKey do
  describe 'key' do
    before do
      # Travis API requests redirect to HTTPS
      stub_request(:any, %r(^http://travis-ci\.org/)).to_return do |request|
        {
          :body => '',
          :status => [301, 'Moved Permanently'],
          :headers => {
            'Location' => request.uri.to_s.sub(/^http/, 'https')
          }
        }
      end
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

      stub_request(:get, "https://travis-ci.org/#{slug}.json").to_return(
        {
          :body => %({"id":4756,"slug":#{MultiJson.dump(slug)},"description":"Travis CLI tool","public_key":#{MultiJson.dump(public_key)},"last_build_id":2619122,"last_build_number":"19","last_build_status":0,"last_build_result":0,"last_build_duration":64,"last_build_language":null,"last_build_started_at":"2012-10-01T04:01:10Z","last_build_finished_at":"2012-10-01T04:01:51Z"}),
          :status => [200, 'OK']
        }
      )

      secure_key = Travis::Cli::SecureKey.new(slug)

      expect{
        secure_key.key
      }.to_not raise_error(Travis::Cli::SecureKey::FetchKeyError)

      secure_key.key.to_pem.should == OpenSSL::PKey::RSA.new(public_key).to_pem
    end
  end
end
