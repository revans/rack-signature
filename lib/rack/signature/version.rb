module RequestSigner
  MAJOR = 0
  MINOR = 0
  PATCH = 1

  def self.version
    [MAJOR, MINOR, PATCH].join('.')
  end

end
