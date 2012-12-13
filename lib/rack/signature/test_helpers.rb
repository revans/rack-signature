require_relative 'build_message'
require_relative 'hmac_signature'

module Rack
  module Signature
    module TestHelpers
      include Rack::Test::Methods

      def generate_shared_token; ::SecureRandom.hex(8); end

      def stringify_request_message(env)
        ::Rack::Signature::BuildMessage.new(env).build!
      end

      def hmac_message(key, message)
        ::Rack::Signature::HmacSignature.new(key, message).sign
      end

      def expected_signature(shared_key, env)
        msg = stringify_request_message(env)
        hmac_message(shared_key, msg)
      end

      def setup_request(uri, opts, key)
        env  = ::Rack::MockRequest.env_for(uri, opts)
        sig  = sign(env, key)
        req  = Rack::Request.new(env)
        query_params = req.params

        [uri, sig, opts, query_params, env]
      end

      def sign(env, key)
        message = stringify_request_message(env)
        hmac_message(key, message)
      end

    end
  end
end
