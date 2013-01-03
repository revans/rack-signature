require_relative 'build_message'
require_relative 'hmac_signature'
require_relative 'sort_query_params'
require 'rack'
require 'json'

module Rack
  module Signature
    module TestHelpers

      def convert_hash_to_string(params)
        params.map { |p| p.join('=')}.join('&')
      end

      def hash_to_sorted_json(obj)
        sorted_hash = SortQueryParams.new(obj).order
        JSON.generate(sorted_hash)
      end

      def sorted_json_to_hash(obj)
        JSON.parse(obj)
      end

      def stringify_request_message(env)
        ::Rack::Signature::BuildMessage.new(env).build!
      end

      def hmac_message(key, message)
        ::Rack::Signature::HmacSignature.new(key, message).sign
      end

      def setup_request(uri, opts, key)
        env = ::Rack::MockRequest.env_for(uri, opts)
        msg = stringify_request_message(env)
        sig = hmac_message(key, msg)

        { signature: sig, message: msg, env: env, key: key }
      end

    end
  end
end
