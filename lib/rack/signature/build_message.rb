require 'rack/request'
require 'json'

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
        get_params.sort.map { |param| param.join('=') }
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

      def get_params
        return request.params unless request.params.empty?
        return read_rack_input
      end

      def read_rack_input
        form_vars = request.env['rack.input'].read
        form_vars = JSON.parse(form_vars) rescue form_vars

        request.env['rack.input'].rewind
        form_vars = Rack::Utils.parse_query(form_vars) rescue form_vars
        form_vars
      end

    end
  end
end
