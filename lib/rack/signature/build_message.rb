require 'rack/request'

module Rack
  module Signature
    class BuildMessage
      attr_reader :request

      # initialize with a hash of options
      #
      # ==== Attributes
      #
      # * +env+ - The rack app env
      #
      def initialize(env)
        @request = ::Rack::Request.new(env)
      end

      def build!
        create_request_message
      end

      def query_string
        request.GET
      end

      def post_body
        request.POST
      end

      def get_parameters
        query_string || post_body
      end

      private

      def sort_query_params
        # request.params.sort.map { |param| param.join('=') }
        # get_params.sort.map { |param| param.join('=') }
        get_parameters.sort.map { |param| param.join('=') }
      end

      def canonicalized_query_params
        sort_query_params.join('&')
      end

      def create_request_message
        request.request_method.upcase +
          request.path_info.downcase +
          request.host.downcase +
          canonicalized_query_params
      end


      def nested_json_ordering
        return request.params unless request.params.empty?

      end


      def get_params
        return request.params unless request.params.empty?

        if request.env['rack.input']
          params = request.env['rack.input'].read


          query_hash = params.split('&').inject({}) do |res, element|
            k,v = element.split('=')
            res.merge({k => v})
          end
        end

        query_hash
      end

    end
  end
end
