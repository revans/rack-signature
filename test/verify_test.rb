require_relative '../lib/rack/signature'
require_relative '../lib/rack/signature/test_helpers'
require 'test_helper'

describe "Verifying a signed request" do
  include Rack::Test::Methods
  include Rack::Signature::TestHelpers

  def setup
    @options    = get_app_options
    @shared_key = key
    @signature  = expected_signature
  end

  let(:app)             { lambda { |env| [200, {}, ['Hello World']] } }
  let(:rack_signature)  { Rack::Signature.new(app, @options) }
  let(:mock_request)    { Rack::MockRequest.new(rack_signature) }

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
      mock_request.post("http://example.com/api/login",
        "Content-Type"    => "application/json",
        "REQUEST_METHOD"  => "POST",
        "X-Auth-Sig"      => @signature,
        "LOCKER-API-KEY"  => '123',
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
    let(:uri)           { "http://example/api/login" }
    let(:query_params)  { "password=1234567&email=me@home.com&name=me&age=1" }
    let(:headers) do
      {"Content-Type"   => "application/json",
      "REQUEST_METHOD"  => "POST",
      "X-Auth-Sig"      => @signature,
      "LOCKER-API-KEY"  => '123'}
    end
    let(:
    let(:response) { mock_request.post(uri, headers, input: query_params) }

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




  # Helper Methods
  def key
    ::Digest::SHA2.hexdigest("shared-key")
  end

  def expected_signature
    "Z0qY8Hy4a/gJkGZI0gklzM6vZztsAVVDjA18vb1BvHg="
  end

  class DemoClass
    def self.get_shared_token(token = '')
      ::Digest::SHA2.hexdigest("shared-key") if token == '123'
    end
  end

  def get_app_options
    { klass: DemoClass, method: :get_shared_token, header_token: 'LOCKER-API-KEY' }
  end

end
