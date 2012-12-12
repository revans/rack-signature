require 'openssl'
require 'base64'

module Rack
  module Signature
    class HmacSignature

      # initialize with the shared key and a hash of options for building the
      # signature
      #
      # ==== Attributes
      #
      # * +key+     - The shared key used as a salt.
      # * +message+ - The built request message
      #
      def initialize(key, message)
        @key, @message = key, message
      end

      # returns a Base64 encoded HMAC of the request plus the private shared key
      def sign
        encode_hmac
      end

      private

      def encode_hmac
        Base64.encode64( hmac_message ).chomp
      end

      def hmac_message
        ::OpenSSL::HMAC.digest(cipher, @key, @message)
      end

      def cipher
        ::OpenSSL::Digest::Digest.new("sha256")
      end

    end
  end
end
