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
        dup._call(env)
      end

      def _call(env)
        if signature_is_valid?(env)
          @app.call(env)
        else
          [401, {'CONTENT_TYPE' => 'application/json'}, 'Access Denied']
        end
      end

      private

      # compares the received Signature against what the Signature should be
      # (computed signature)
      def signature_is_valid?(env)
        return true if html_request?(env)

        # grab and compute the X-AUTH-SIG
        signature_sent    = env["HTTP_X_AUTH_SIG"]
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
        token = env[options[:header_token]]

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
        log "WHAT MODEL WILL BE CALLED:     #{options[:klass]}##{options[:method]} pulling api token from #{options[:header_token]} which is #{env[options[:header_token]]}"
        log "CALL RAILS MODEL:              #{options[:klass].send(options[:method].to_s, (env[options[:header_token]])).inspect}"
        log "SHARED_KEY from Rails:         #{shared_key(env).inspect}"
        log "CONTENT_TYPE of request:       #{env['CONTENT_TYPE'].inspect}"
        log "QUERY SENT:                    #{builder.query.inspect}"
        log "MESSAGE built by rails:        #{builder.build!.inspect}"
        log "HMAC built by rails:           #{HmacSignature.new(shared_key(env), builder.build!).sign.inspect}"
        log "HMAC received from client      #{env['HTTP_X_AUTH_SIG'].inspect}"
        log "API KEY received from client   #{env['HTTP_LOCKER_API_KEY'].inspect}"
        log "RACK ENV:                      #{env.inspect}"
      end

      def log(msg)
        options[:logger].info(msg)
      end

    end
  end
end
