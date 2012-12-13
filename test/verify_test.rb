require_relative '../lib/rack/signature'
require 'test_helper'

describe "Verifying a signed request" do
  include Rack::Signature::TestHelpers

  TOKEN = ::SecureRandom.hex(8)
  def setup
    @klass_options = {klass: DemoClass, method: :get_shared_token, header_token: 'LOCKER-API-KEY'}
    @req = setup_request("http://example.com/api/login",
      {"Content-Type"   => "application/json",
      "REQUEST_METHOD"  => "POST",
      "LOCKER-API-KEY"  => '123',
      input: "password=123456&email=me@home.com&name=me&age=1"
      }, TOKEN)
    @uri, @headers, @params, @env, @sig, @msg = @req
  end

  let(:app)             { lambda { |env| [200, {}, ['Hello World']] } }
  let(:rack_signature)  { Rack::Signature.new(app, @klass_options) }
  let(:mock_request)    { Rack::MockRequest.new(rack_signature) }

  class DemoClass
    def self.get_shared_token(token = '')
      TOKEN if token
    end
  end

  let(:req) { @req }
  let(:uri) { @uri }
  let(:signature) { @sig }
  let(:headers) { @headers }
  let(:query_params) { @params }
  let(:env) { @env }

  describe "when a request is made without a signature" do
    before {
      @response = mock_request.get '/api/login?password=123456&email=me@home.com'
    }
    let(:response) { @response }

    it 'returns a 403 status' do
      assert_equal 403, response.status
    end

    it 'returns "Invalid Signature" as the response body' do
      assert_equal 'Invalid Signature', response.body
    end

    it 'returns the correct header' do
      expected_header = {"Content-Type"=>"text/html", "Content-Length"=>"17"}
      assert_equal expected_header, response.header
    end
  end

  describe "when a requests is sent with a valid signature" do
    let(:response) do
      mock_request.post(uri,
        "Content-Type"    => "application/json",
        "REQUEST_METHOD"  => "POST",
        "LOCKER-API-KEY"  => '123',
        "X-Auth-Sig"      => signature,
        input: "password=123456&email=me@home.com&name=me&age=1")
    end

    it 'will return a 200 status' do
      assert_equal 200, response.status
    end

    it 'will call the next rack app' do
      assert_equal 'Hello World', response.body
    end
  end


  describe "when a requests is sent with a tampered signature" do
    let(:response) do
      mock_request.post(uri,
        {"Content-Type"   => "application/json",
        "REQUEST_METHOD"  => "POST",
        "LOCKER-API-KEY"  => '123',
        "X-Auth-Sig"      => signature,
        input: "password=1234567&email=me@home.com&name=me&age=1"})
    end

    it 'returns a 403 status' do
      assert_equal 403, response.status
    end

    it 'returns "Invalid Signature" as the response body' do
      assert_equal 'Invalid Signature', response.body
    end

    it 'returns the correct header' do
      expected_header = {"Content-Type"=>"text/html", "Content-Length"=>"17"}
      assert_equal expected_header, response.header
    end
  end

end
