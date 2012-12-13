require 'rack/test'
require 'rack/mock'

require_relative 'build_message'
require_relative 'hmac_signature'

module Rack
  module Signature
    module TestHelpers
      include Rack::Test::Methods

      def shared_key
        @key ||= ::SecureRandom.hexdigest(8)
      end

      def stringify_request_message(env)
        ::Rack::Signature::BuildMessage.new(env).build!
      end

      def expected_hmac(shared_key, message)
        ::Rack::Signature::HmacSignature.new(key, message).sign
      end

      def rack_signature(options = klass_options)
        Rack::Signature.new(lambda {|env| [200, {}, ['Hello World']]}, options)
      end

      def mock_request
        Rack::MockRequest.new(rack_signature)
      end

      class DemoClass
        def self.get_shared_token(token = '')
          shared_key, if token == '123'
        end
      end

      def klass_options
        {klass: DemoClass, method: :get_shared_token, header_token: 'LOCKER-API-KEY'}
      end

    end
  end
end
