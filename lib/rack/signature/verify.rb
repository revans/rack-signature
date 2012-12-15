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
        [401, {'CONTENT_TYPE' => 'application/json'}, 'Access Denied']
      end

      # compares the received Signature against what the Signature should be
      # (computed signature)
      def signature_is_valid?(env)
        return true if html_request?(env)

        # grab and compute the X-AUTH-SIG
        signature_sent    = env["X_AUTH_SIG"]
        actual_signature  = compute_signature(env)

        # are they the same?
        signature_sent.to_s == actual_signature.to_s
      end

      # builds the request message and tells HmacSignature to sign the message
      def compute_signature(env)
        message = BuildMessage.new(env).build!
        HmacSignature.new(shared_key(env), message).sign
      end

      # FIXME: This is here for now for a quick implementation within another
      # app. This will eventually need to be a rack app itself
      def shared_key(env)
        token = (env[options[:token]] || "")
        return '' if token.nil? || token == ''

        shared_token = options[:klass].send(options[:method].to_s, token)
        shared_token.to_s
      end

      # we only want to use this if the request is an api request
      def html_request?(env)
        debug(env) if options[:debug]
        (env['CONTENT_TYPE'] || "").to_s !~ /json/i
      end

      def debug(env)
        builder = BuildMessage.new(env)
        log "SHARED_KEY from Rails:     #{shared_key(env).inspect}"
        log "CONTENT_TYPE of request:   #{env['CONTENT_TYPE'].inspect}"
        log "QUERY SENT:                #{builder.query.inspect}"
        log "MESSAGE built by rails:    #{builder.build!.inspect}"
        log "HMAC built by rails:       #{HmacSignature.new(shared_key(env), builder.build!).sign.inspect}"
        log "HMAC received from client  #{env['X_AUTH_SIG'].inspect}"
      end

      def log(msg)
        STDOUT.puts(msg)
      end

    end
  end
end
