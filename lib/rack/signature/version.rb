module Rack
  module Signature
    MAJOR = 0
    MINOR = 0
    PATCH = 6

    def self.version
      [MAJOR, MINOR, PATCH].join('.')
    end
  end
end
