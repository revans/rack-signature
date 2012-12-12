require_relative '../lib/request_signer/version'
require 'minitest/autorun'

class RequestSignerTest < MiniTest::Unit::TestCase
  def test_version
    expected_version = '0.0.1'
    assert_equal expected_version, RequestSigner.version
  end
end
