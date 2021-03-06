module Rack
  module Signature
    MAJOR = 0
    MINOR = 1
    PATCH = 2

    def self.version
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
