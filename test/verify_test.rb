require_relative '../lib/rack/signature'
require 'test_helper'

describe "Verifying a signed requests" do
  include Rack::Signature::TestHelpers
  TOKEN = ::SecureRandom.hex(8)
  class DemoClass
    def self.get_shared_token(token = '')
      return "1" if token.nil?
      TOKEN
    end
  end
  let(:klass_options) do
    {klass: DemoClass, method: :get_shared_token, header_token: 'LOCKER_API_KEY', debug: false}
  end
  let(:app)             { lambda { |env| [200, {}, ['Hello World']] } }
  let(:rack_signature)  { Rack::Signature.new(app, klass_options) }
  let(:mock_request)    { Rack::MockRequest.new(rack_signature) }

  describe "when it is a POST via JSON" do
    let(:uri) { "http://example.com/api/login" }
    let(:body) do
      { password: '123456', email: 'me@home.com', name: 'some dude', age: 1 }
    end

    def request_array
      setup_request(uri, {
        "CONTENT_TYPE"    => "application/json",
        "REQUEST_METHOD"  => "POST",
        "LOCKER_API_KEY"  => "123",
        input: convert_hash_to_string(body)
      }, TOKEN)
    end
    let(:expected_env)    { request_array[:env] }
    let(:expected_msg)    { request_array[:message] }
    let(:expected_sig)    { request_array[:signature] }

    describe "a successful JSON POST" do
      let(:mock_response) do
        mock_request.post(uri,{
          "CONTENT_TYPE"    => "application/json",
          "REQUEST_METHOD"  => "POST",
          "LOCKER_API_KEY"  => "123",
          "X_AUTH_SIG"      => expected_sig,
          input: convert_hash_to_string(body)
        })
      end

      it 'will return a 200 Status' do
        assert_equal 200, mock_response.status
      end

      it 'will have a response body' do
        assert_equal 'Hello World', mock_response.body
      end

      it 'has the correct built message' do
        assert_equal "POST/api/loginexample.comage=1&email=me@home.com&name=some dude&password=123456", expected_msg
      end
    end

    describe "when the query string is tampered with during a JSON POST" do
      let(:mock_response) do
        mock_request.post(uri,{
          "CONTENT_TYPE"    => "application/json",
          "REQUEST_METHOD"  => "POST",
          "LOCKER_API_KEY"  => "123",
          "X_AUTH_SIG"      => expected_sig,
          input: convert_hash_to_string(body.merge(email: 'attacker@home.com'))
        })
      end

      it 'will return a 401 Status' do
        assert_equal 401, mock_response.status
      end

      it 'will have a response body denying access' do
        assert_equal 'Access Denied', mock_response.body
      end

      it 'has the correct built message' do
        assert_match "some dude", expected_msg
      end
    end
  end

  describe "when it is a GET via JSON" do
    let(:uri) { "http://example.com/api/login" }
    let(:body) do
      { password: '123456', email: 'me@home.com', name: 'some dude', age: 1 }
    end

    def request_array
      setup_request(uri, {
        "CONTENT_TYPE"    => "application/json",
        "REQUEST_METHOD"  => "GET",
        "LOCKER_API_KEY"  => "123",
        "QUERY_STRING"    => convert_hash_to_string(body)
      }, TOKEN)
    end
    let(:expected_env)    { request_array[:env] }
    let(:expected_msg)    { request_array[:message] }
    let(:expected_sig)    { request_array[:signature] }

    describe "a successful JSON GET request" do
      let(:mock_response) do
        mock_request.post(uri,{
          "CONTENT_TYPE"    => "application/json",
          "REQUEST_METHOD"  => "GET",
          "LOCKER_API_KEY"  => "123",
          "QUERY_STRING"    => convert_hash_to_string(body),
          "X_AUTH_SIG"      => expected_sig
        })
      end

      it 'will return a 200 Status' do
        assert_equal 200, mock_response.status
      end

      it 'will have a response body' do
        assert_equal 'Hello World', mock_response.body
      end

      it 'has the correct built message' do
        assert_match "some dude", expected_msg
      end
    end

    describe "when the query string is tampered with during a JSON GET request" do
      let(:mock_response) do
        mock_request.post(uri,{
          "CONTENT_TYPE"    => "application/json",
          "REQUEST_METHOD"  => "GET",
          "LOCKER_API_KEY"  => "123",
          "QUERY_STRING"    => convert_hash_to_string(body.merge(password: 654321)),
          "X_AUTH_SIG"      => expected_sig
        })
      end

      it 'will return a 401 Status' do
        assert_equal 401, mock_response.status
      end

      it 'will have a response body denying access' do
        assert_equal 'Access Denied', mock_response.body
      end

      it 'has the correct built message' do
        assert_match "some dude", expected_msg
      end
    end
  end

  describe "when there is not token" do
    let(:uri) { "http://example.com/api/register" }
    let(:body) do
      { password: '123456', email: 'me@home.com', name: 'some dude', age: 1 }
    end

    def request_array
      setup_request(uri, {
        "CONTENT_TYPE"    => "application/json",
        "REQUEST_METHOD"  => "POST",
        "QUERY_STRING"    => convert_hash_to_string(body)
      }, "1")
    end
    let(:expected_env)    { request_array[:env] }
    let(:expected_msg)    { request_array[:message] }
    let(:expected_sig)    { request_array[:signature] }
    let(:expected_key)    { request_array[:key] }

    describe "when no token is required, but the request must still be signed" do
      let(:mock_response) do
        mock_request.post(uri,{
          "CONTENT_TYPE"    => "application/json",
          "REQUEST_METHOD"  => "POST",
          "QUERY_STRING"    => convert_hash_to_string(body),
          "X_AUTH_SIG"      => expected_sig
        })
      end

      it 'will return a 200 status' do
        assert_equal 200, mock_response.status
      end

      it 'will have a response body' do
        assert_equal 'Hello World', mock_response.body
      end

      it 'has the correct built message' do
        assert_equal "POST/api/registerexample.comage=1&email=me@home.com&name=some dude&password=123456", expected_msg
      end
    end
  end
end
