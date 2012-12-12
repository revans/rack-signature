# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/signature/version'

Gem::Specification.new do |gem|
  gem.name          = "rack-signature"
  gem.version       = Rack::Signature.version
  gem.authors       = ["Robert Evans"]
  gem.email         = ["robert@codewranglers.org"]
  gem.description   = %q{Rack Middleware for verifying signed requests}
  gem.summary       = %q{Rack Middleware for verifying signed requests}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'rack'

  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'rack-test'
end
