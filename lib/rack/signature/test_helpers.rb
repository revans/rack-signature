require_relative 'build_message'
require_relative 'hmac_signature'

module Rack
  module Signature
    module TestHelpers
      include Rack::Test::Methods

      # def generate_shared_token; ::SecureRandom.hex(8); end
      def generate_shared_token; "a8a5ac6e39f1f5cd"; end

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
        msg  = stringify_request_message(env)
        sig  = hmac_message(key, msg)
        req  = Rack::Request.new(env)
        query_params = req.params

        [uri, opts, query_params, env, sig, msg]
      end

    end
  end
end
