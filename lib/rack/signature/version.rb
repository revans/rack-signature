module Rack
  module Signature
    MAJOR = 0
    MINOR = 0
    PATCH = 8

    def self.version
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
