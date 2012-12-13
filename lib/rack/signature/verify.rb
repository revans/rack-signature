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
      attr_reader :options

      # Initializes the Rack Middleware
      #
      # ==== Attributes
      #
      # * +app+     - A Rack app
      # * +options+ - A hash of options
      #
      def initialize(app, options)
        @app, @options = app, options
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
        HmacSignature.new(shared_key(env), message).sign
      end

      # FIXME: This is here for now for a quick implementation within another
      # app. This will eventually need to be a rack app itself
      def shared_key(env)
        token = env["HTTP_#{options[:header_token]}"]
        return '' if token.nil? || token == ''
        options[:klass].send(options[:method].to_s, token)
      end

    end
  end
end
