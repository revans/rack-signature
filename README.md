[![Build Status](https://secure.travis-ci.org/revans/rack-signature.png)](https://travis-ci.org/revans/rack-signature)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/revans/rack-signature)

# This is currently still being worked on and does have several known bugs.

This is an alpha release, a pre 1.0 version. If you use this, be aware it's in
its infancy.

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

This is meant to be added to a Rails initializer like so:

```ruby
Rails.application.config.middleware.use Rack::Signature,
  klass: ClassWithSharedKey,
  method: 'method_within_class',
  header_token: 'http header used to hold the api key'
```
### Overview

This gem is assumed to be used within a rails application. It computes the HMAC
Signature internally and only sends a (single) request over the network when
Signatures fail to match; sending a 401. Otherwise, it makes no requests - only
accepts incoming JSON Api requests.


This gem will build an HMAC Signature based off an incoming request made to its
JSON Api initiated by some external client. Once it builds the "expected" HMAC
Signature, it will compare its Signature against the Signature that was sent by
the external client. If they match, the request is allowed to continue to the
Rails application. If it fails, this gem will send back a 401 response from its
own internal Rack application.


### Options explained:

#### klass

The name of the class within the rails application that can be used to query for
a model's shared key.

It is assumed that each consumer has it's own unique shared key; similar to
Oauth.

#### method

The method within the +klass+ that will be called to request a shared key to
build the HMAC. This is a class level method.

#### header_token

This is a bad name. It will be changed.

This is the name of the HTTP Header that holds the Api Key that is associated
with the consumer's account. It is used as the authentication as well as a way
to get the consumer's account to retreive the +shared key+.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
