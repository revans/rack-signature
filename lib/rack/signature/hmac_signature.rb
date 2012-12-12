require 'openssl'
require 'base64'

require_relative 'build_message'

module RequestSigner
  class HmacSignature
    attr_reader :options

    # initialize with the shared key and a hash of options for building the
    # signature
    #
    # ==== Attributes
    #
    # * +key+     - The shared key used as a salt.
    # * +options+ - A hash of options about the request.
    #
    # ==== Options
    #
    # The options hash is required and used for creating the HMAC signature. The
    # required options are:
    #
    # +request_method+  - The type of request: GET/POST/PUT/DELETE/PATCH
    # +host+            - The Api server domain: apiserver.com
    # +path+            - The URI Api path: /api/person/bob
    # +query_params+    - The query params or post body within the request
    #
    def initialize(key, options)
      @key, @options = key, options
    end

    # returns a Base64 encoded HMAC of the request plus the private shared key
    def sign
      encode(build_message)
    end

    # using dependency injection to make it easy to test in isolation
    def build_message(builder = BuildMessage)
      builder.new(options).build!
    end

    private

    def encode(message)
      Base64.encode64(hmac(build_message)).chomp
    end

    def hmac(message)
      ::OpenSSL::HMAC.digest(cipher, @key, message)
    end

    def cipher
      ::OpenSSL::Digest::Digest.new("sha256")
    end

  end
end
