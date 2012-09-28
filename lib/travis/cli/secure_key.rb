# encoding: utf-8
require 'net/https'
require 'multi_json'
require 'openssl'
require 'base64'

module Travis
  class Cli
    class SecureKey
      class FetchKeyError < StandardError; end
      attr_reader :slug

      def initialize(slug)
        @slug = slug
      end

      def encrypt(secret)
        encrypted = key.public_encrypt(secret)
      end

      def key
        @key ||= fetch_key
      end

      def fetch_key
        uri = URI.parse("https://travis-ci.org/#{slug}.json")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        request = Net::HTTP::Get.new(uri.request_uri)

        response = http.request(request)

        if response.code.to_i == 200
          public_key = MultiJson.decode(response.body)['public_key']
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
