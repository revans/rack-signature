require_relative '../lib/rack/signature'
require 'test_helper'

describe "Verifying a signed request" do
  include Rack::Test::Methods

  describe "when there is a valid signed request" do
    def app
      ::Rack::Builder.new do
        use ::Rack::Signature, "e262c41ad8d6736747d49ebb30e157bbc01e4e42dceb0fa75b184a170240a87d"
        headers = {
          'X-Auth-Sig'    => "nTvaoB4Yg1fAsKR81SzTRrCjTz8KImAIYVbgN4WjnX8=",
          'Content-Type'  => 'application/json'
        }
        run lambda { |env| [200, headers, ''] }
      end.to_app
    end

    it 'the signture will be valid' do
      get "/api/login?password=123456&email=me@home.com"
      assert last_response.ok?
    end
  end
end
