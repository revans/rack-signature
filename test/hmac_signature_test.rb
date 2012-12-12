require_relative '../lib/rack/signature/hmac_signature'
require 'test_helper'

module Rack::Signature
  class HmacSignatureTest < MiniTest::Unit::TestCase

    def test_valid_signature
      assert_equal expected_signature,
        HmacSignature.new(key, request_message).sign
    end

    def test_tampered_query_params
      tampered_message = "POST/api/loginexample.comage=1&email=me@home.com&name=me&password=3456"

      refute_equal expected_signature,
        HmacSignature.new(key, tampered_message).sign
    end

    def test_different_shared_key
      refute_equal expected_signature,
        HmacSignature.new("123", request_message).sign
    end

    def test_missing_options
      missing_request_params = "POST/api/loginexample.comemail=me@home.com&password=123456"
      refute_equal expected_signature,
        HmacSignature.new(key, missing_request_params).sign
    end

    # Helper methods
    def request_message
      "POST/api/loginexample.comage=1&email=me@home.com&name=me&password=123456"
    end

    def key
      ::Digest::SHA2.hexdigest("shared-key")
    end

    def expected_signature
      "Z0qY8Hy4a/gJkGZI0gklzM6vZztsAVVDjA18vb1BvHg="
    end

  end
end
