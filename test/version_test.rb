require_relative '../lib/rack/signature/version'
require 'minitest/autorun'

class VersionTest < MiniTest::Unit::TestCase
  def test_version
    expected_version = '0.0.1'
    assert_equal expected_version, Rack::Signature.version
  end
end
