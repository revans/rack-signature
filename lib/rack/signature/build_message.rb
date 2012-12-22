require 'rack/request'
require 'json'

require_relative 'build_post_body'

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
        read_request_and_build_message
      end

      private

      def read_request_and_build_message
        form_vars = read_rack_input
        if form_vars.nil? || form_vars == ''
          for_query_string(request.params)
        else
          for_post_body(form_vars)
        end
      end

      def for_query_string(params)
        sorted_params = params.sort.map { |p| p.join('=') }.join('&')
        build_request_message(sorted_params)
      end

      def for_post_body(params)
        sorted_json = BuildPostBody.new(params).sorted_json
        build_request_message(sorted_json)
      end

      def build_request_message(params)
        request.request_method.upcase +
          request.path_info.downcase +
          request.host.downcase +
          params
      end

      def read_rack_input
        form_vars = request.env['rack.input'].read
        form_vars = JSON.parse(form_vars) rescue form_vars
        request.env['rack.input'].rewind
        form_vars
      end

    end
  end
end
