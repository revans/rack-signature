require_relative '../lib/request_signer/build_message'
require 'test_helper'

module RequestSigner
  class BuildMessageTest < MiniTest::Unit::TestCase
    include TestingHelpers

    def test_build_with_a_valid_request
      assert_equal valid_string_message, BuildMessage.new(valid_options).build!
    end

    def test_build_with_missing_request_options
      assert_equal missing_string_message, BuildMessage.new(missing_options).build!
    end
  end
end
