require_relative 'hmac_signature'

# A Rack app to verify requests based on a computed signature passed within the
# HTTP Header: X-Auth-Sig.
#
# This app will rebuild the signature and then compare its own computed HMAC
# against the one sent from the client to verify authenticity.
#
module Rack
  module Signature
    class Verify

      # Initializes the Rack Middleware
      #
      # ==== Attributes
      #
      # * +app+     - A Rack app
      # * +key+     - The shared key used as a salt.
      #
      def initialize(app, key)
        @app, @key = app, key
      end

      def call(env)
        if signature_is_valid?(env)
          @app.call(env)
        else
          invalid_signature
        end
      end

      private

      # if the signature is invalid we send back this Rack app
      def invalid_signature
        [403, {'Content-Type' => 'text/html'}, 'Invalid Signature']
      end

      # compares the received Signature against what the Signature should be
      # (computed signature)
      def signature_is_valid?(env)
        received_signature = env["HTTP_X_AUTH_SIG"]
        expected_signature = compute_signature(env)

        expected_signature == received_signature
      end

      # builds the request message and tells HmacSignature to sign the message
      def compute_signature(env)
        message = BuildMessage.new(env).build!
        HmacSignature.new(@key, message).sign
      end

    end
  end
end
