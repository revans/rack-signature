require_relative '../lib/rack/signature/hmac_signature'
require 'test_helper'

module Rack::Signature
  class HmacSignatureTest < MiniTest::Unit::TestCase
    include TestingHelpers

    def test_valid_signature
      assert_equal valid_signature, HmacSignature.new(key, valid_options).sign
    end

    def test_tampered_query_params
      refute_equal valid_signature, HmacSignature.new(key, tampered_options).sign
    end

    def test_different_shared_key
      refute_equal valid_signature, HmacSignature.new(invalid_key, valid_options).sign
    end

    def test_missing_options
      refute_equal valid_signature, HmacSignature.new(key, missing_options).sign
    end

    def test_computed_invalid_signature
      refute_equal invalid_signature, HmacSignature.new(key, valid_options).sign
    end

  end
end
