require_relative '../lib/rack/signature'
require 'test_helper'

describe "Verifying a signed requests" do
  include Rack::Signature::TestHelpers
  TOKEN = ::SecureRandom.hex(8)
  class DemoClass
    def self.get_shared_token(token = '')
      TOKEN if token
    end
  end
  let(:klass_options) do
    {klass: DemoClass, method: :get_shared_token, token: 'LOCKER_API_KEY'}
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
end









describe "Verifying a signed request" do
  # include Rack::Signature::TestHelpers

  # TOKEN = ::SecureRandom.hex(8)
  # def setup
  #   @klass_options = {klass: DemoClass, method: :get_shared_token, header_token: 'LOCKER_API_KEY'}
  #   @req = setup_request("http://example.com/api/login",
  #     {"CONTENT_TYPE"   => "application/json",
  #     "REQUEST_METHOD"  => "POST",
  #     "LOCKER_API_KEY"  => '123',
  #     input: "password=123456&email=me@home.com&name=me&age=1"
  #     }, TOKEN)
  #   @uri, @headers, @params, @env, @sig, @msg = @req
  # end

  # let(:app)             { lambda { |env| [200, {}, ['Hello World']] } }
  # let(:rack_signature)  { Rack::Signature.new(app, @klass_options) }
  # let(:mock_request)    { Rack::MockRequest.new(rack_signature) }

  # class DemoClass
  #   def self.get_shared_token(token = '')
  #     TOKEN if token
  #   end
  # end

  # let(:req) { @req }
  # let(:uri) { @uri }
  # let(:signature) { @sig }
  # let(:headers) { @headers }
  # let(:query_params) { @params }
  # let(:env) { @env }



  # describe "when a request is made without a signature" do
  #   before {
  #     @response = mock_request.get '/api/login?password=123456&email=me@home.com'
  #   }
  #   let(:response) { @response }

  #   it 'returns a 403 status' do
  #     assert_equal 403, response.status
  #   end

  #   it 'returns "Invalid Signature" as the response body' do
  #     assert_equal 'Invalid Signature', response.body
  #   end

  #   it 'returns the correct header' do
  #     expected_header = {"Content-Type"=>"text/html", "Content-Length"=>"17"}
  #     assert_equal expected_header, response.header
  #   end
  # end


  # describe "when a requests is sent with a valid signature" do
  #   let(:response) do
  #     mock_request.post(uri,
  #       "CONTENT_TYPE"    => "application/json",
  #       "REQUEST_METHOD"  => "POST",
  #       "LOCKER_API_KEY"  => '123',
  #       "X_AUTH_SIG"      => signature,
  #       input: "password=123456&email=me@home.com&name=me&age=1")
  #   end

  #   it 'will return a 200 status' do
  #     assert_equal 200, response.status
  #   end

  #   it 'will call the next rack app' do
  #     assert_equal 'Hello World', response.body
  #   end
  # end


  # describe "when a requests is sent with a tampered signature" do
  #   let(:response) do
  #     mock_request.post(uri,
  #       {"CONTENT_TYPE"   => "application/json",
  #       "REQUEST_METHOD"  => "POST",
  #       "LOCKER_API_KEY"  => '123',
  #       "X_AUTH_SIG"      => signature,
  #       input: "password=1234567&email=me@home.com&name=me&age=1"})
  #   end

  #   it 'returns a 403 status' do
  #     assert_equal 403, response.status
  #   end

  #   it 'returns "Invalid Signature" as the response body' do
  #     assert_equal 'Invalid Signature', response.body
  #   end

  #   it 'returns the correct header' do
  #     expected_header = {"CONTENT_TYPE"=>"application/json", "CONTENT_LENGTH"=>"17"}
  #     assert_equal expected_header, response.header
  #   end
  # end

end
