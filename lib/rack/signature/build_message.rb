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

      private

      def sort_query_params
        request.params.sort.map { |param| param.join('=') }
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

    end
  end
end
