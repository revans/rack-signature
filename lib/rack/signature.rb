require_relative 'signature/version'
require_relative 'signature/build_message'
require_relative 'signature/hmac_signature'
require_relative 'signature/verify'

module Rack
  module Signature
    def self.new(app, options)
      Verify.new(app, options)
    end
  end
end
