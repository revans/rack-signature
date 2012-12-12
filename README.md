[![Build Status](https://travis-ci.org/revans/rack-signature.png)](https://travis-ci.org/revans/rack-signature)

# Rack::Signature

Rack Middleware used to verify signed requests.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-signature'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-signature

## Usage

  use Rack::Signature, 'your-shared-key'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
