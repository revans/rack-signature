require_relative 'test_helper'
require 'json'

module Rack::Signature
  class BuildMessageTest < Minitest::Test
    include TestHelper

    def test_get_query
      env = Rack::MockRequest.env_for(
        "http://localhost:3000/api/register",
        "CONTENT_TYPE"  => 'application/json',
        'REQUEST_METHOD' => 'POST',
        input: { 'email' => 'demo@example.com', 'password' => '123456' }.to_json)

      assert_equal 'POST/api/registerlocalhost{"email":"demo@example.com","password":"123456"}', BuildMessage.new(env).build!
    end

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
        input: {'passord' => '123456', 'email' => 'me@home.com', 'age' => 1}.to_json
      )

      message = 'POST/api/loginexample.com{"age":1,"email":"me@home.com","passord":"123456"}'
      assert_equal message,
        BuildMessage.new(env).build!
    end

    def test_query_string
      env = Rack::MockRequest.env_for(
        "http://example.com/api/login?password=elf&email=santa@claus.com&name=santa",
        "Content-Type"    => "application/json",
        "REQUEST_METHOD"  => "GET"
      )

      assert_equal "GET/api/loginexample.comemail=santa@claus.com&name=santa&password=elf",
        BuildMessage.new(env).build!
    end

    def test_nested_json_structure
      env = Rack::MockRequest.env_for(
        "http://example.com/api/create?name=me", {
          method: 'POST',
          content_type: 'application/json',
          input: read_json('data')
      })
      ordered_json = read_json('ordered_json_data').chomp
      message = "POST/api/createexample.com#{ordered_json}"

      assert_equal message, BuildMessage.new(env).build!
    end

  end
end
