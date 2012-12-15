require_relative '../lib/rack/signature/build_message'
require 'test_helper'

module Rack::Signature
  class BuildMessageTest < MiniTest::Unit::TestCase

    def test_build_with_a_valid_request
      env = Rack::MockRequest.env_for(
        "http://example.com/api/login?password=123456&email=me@home.com")

      assert_equal "GET/api/loginexample.comemail=me@home.com&password=123456",
        BuildMessage.new(env).build!
    end

    def test_build_order
      env = Rack::MockRequest.env_for(
        "http://example.com/api/login",
        "Content-Type"    => "application/json",
        "REQUEST_METHOD"  => "POST",
        input: "password=123456&email=me@home.com&name=me&age=1"
      )

      assert_equal "POST/api/loginexample.comage=1&email=me@home.com&name=me&password=123456",
        BuildMessage.new(env).build!
    end

    def test_query_string
      env = Rack::MockRequest.env_for(
        "http://example.com/api/login?password=elf&email=santa@claus.com&name=santa",
        "Content-Type"    => "application/json",
        "REQUEST_METHOD"  => "POST"
      )

      assert_equal "POST/api/loginexample.comemail=santa@claus.com&name=santa&password=elf",
        BuildMessage.new(env).build!
    end

  end
end
