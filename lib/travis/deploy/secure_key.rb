# encoding: utf-8
require 'net/http'
require 'net/https'
require 'multi_json'
require 'openssl'
require 'base64'

module Travis
  class Deploy
    class SecureKey
      class FetchKeyError < StandardError; end
      attr_reader :slug, :host

      def initialize(slug, host = nil)
        @slug = slug
        @host = host || "api.travis-ci.org"
      end

      def encrypt(secret)
        encrypted = key.public_encrypt(secret)
      end

      def key
        @key ||= fetch_key
      end

      def fetch_key
        uri = URI.parse("https://#{host}/repos/#{slug}/key")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(uri.request_uri, 'Accept' => 'application/vnd.travis-ci.2+json')

        response = http.request(request)

        if response.code.to_i == 200
          body = MultiJson.decode(response.body)
          public_key = body['key']
          begin
            OpenSSL::PKey::RSA.new(public_key)
          rescue OpenSSL::PKey::RSAError
            # unsure why, but it seems that some keys are generated in a
            # wrong way
            public_key.gsub!('RSA PUBLIC KEY', 'PUBLIC KEY')
            OpenSSL::PKey::RSA.new(public_key)
          end
        else
          raise FetchKeyError
        end
      end
    end
  end
end
