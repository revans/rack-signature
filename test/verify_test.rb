require_relative '../lib/rack/signature'
require 'test_helper'

describe "Verifying a signed request" do
  include Rack::Test::Methods

  def setup
    @shared_key = key
    @signature  = expected_signature
  end

  let(:app)             { lambda { |env| [200, {}, ['Hello World']] } }
  let(:rack_signature)  { Rack::Signature.new(app, @shared_key) }
  let(:mock_request)    { Rack::MockRequest.new(rack_signature) }

  describe "when a request is made without a signature" do
    let(:response) { mock_request.get '/api/login?password=123456&email=me@home.com' }

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
        "HTTP_X_AUTH_SIG" => @signature,
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
      mock_request.post("http://example.com/api/login",
        "Content-Type"    => "application/json",
        "REQUEST_METHOD"  => "POST",
        "HTTP_X_AUTH_SIG" => @signature,
        input: "password=1234567&email=me@home.com&name=me&age=1")
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

  # Helper Methods
  def key
    ::Digest::SHA2.hexdigest("shared-key")
  end

  def expected_signature
    "Z0qY8Hy4a/gJkGZI0gklzM6vZztsAVVDjA18vb1BvHg="
  end

end
