require 'minitest/autorun'

module RequestSigner
  module TestingHelpers
    def key
      "e262c41ad8d6736747d49ebb30e157bbc01e4e42dceb0fa75b184a170240a87d"
    end

    def invalid_key
      "262c41ad8d6736747d49ebb30e157bbc01e4e42dceb0fa75b184a170240a87d"
    end

    def valid_signature
      "nTvaoB4Yg1fAsKR81SzTRrCjTz8KImAIYVbgN4WjnX8="
    end

    def invalid_signature
      "TvaoB4Yg1fAsKR81SzTRrCjTz8KImAIYVbgN4WjnX8="
    end

    def valid_options
      {
        'request_method' => 'POST',
        'host' => 'domain.com',
        'path' => '/api/login',
        'query_params' =>  {
          'password'  => '123456',
          'email'     => 'me@home.com',
          'name'      => 'me',
          'age'       => 1
        }
      }
    end

    def valid_string_message
      "POSTdomain.com/api/loginage=1&email=me@home.com&name=me&password=123456"
    end

    def missing_options
      {
        'request_method' => 'POST',
        'query_params' =>  {
          'password'  => '123456',
          'email'     => 'me@home.com'
        }
      }
    end

    def missing_string_message
      "POSTemail=me@home.com&password=123456"
    end

    def tampered_options
      {
        'request_method' => 'POST',
        'host' => 'domain.com',
        'path' => '/api/login',
        'query_params' =>  {
          'password'  => 'abc123',
          'email'     => 'me@home.com',
          'name'      => 'me',
          'age'       => 1
        }
      }
    end
  end
end
