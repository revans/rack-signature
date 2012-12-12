
class BuildMessage
  attr_reader :options

  # initialize with a hash of options
  #
  # ==== Attributes
  #
  # * +options+ - A hash of options about the request.
  #
  # ==== Options
  #
  # The options hash is required and the below keys of the hash are also
  # required.
  #
  # +request_method+  - The type of request: GET/POST/PUT/DELETE/PATCH
  # +host+            - The Api server domain: apiserver.com
  # +path+            - The URI Api path: /api/person/bob
  # +query_params+    - The query params or post body within the request
  #
  def initialize(options)
    @options = options
  end

  def build!
    create_request_string
  end

  private

  def sort_params(params)
    return [] if params.empty?
    params.sort.map { |param| param.join('=') }
  end

  def canonicalized_params(params)
    sort_params(params).join('&')
  end

  def create_request_string
    options.fetch('request_method', '') +
      options.fetch('host', '') +
      options.fetch('path', '') +
      canonicalized_params(options.fetch('query_params', []))
  end
end
