require_relative 'build_message'
require_relative 'hmac_signature'

module Rack
  module Signature
    module TestHelpers
      include Rack::Test::Methods

      def generate_shared_token; ::SecureRandom.hex(8); end

      def convert_hash_to_string(params)
        params.map {|p| p.join('=')}.join('&')
      end

      def stringify_request_message(env)
        ::Rack::Signature::BuildMessage.new(env).build!
      end

      def hmac_message(key, message)
        ::Rack::Signature::HmacSignature.new(key, message).sign
      end

      def setup_request(uri, opts, key)
        env  = ::Rack::MockRequest.env_for(uri, opts)
        msg  = stringify_request_message(env)
        sig  = hmac_message(key, msg)


        { signature: sig, message: msg, env: env, key: key }
      end

    end
  end
end
