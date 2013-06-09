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

      def query
        sort_params
      end

      private

      def read_request_and_build_message
        params = sort_params
        build_request_message(params)
      end

      def sort_params
        empty_form? ? for_query_string(request.params) : for_post_body(form_vars)
      end

      def form_vars
        @form_vars ||= read_rack_input
      end

      def empty_form?
        form_vars.nil? || form_vars == ''
      end

      def for_query_string(params)
        @sorted_params ||= params.sort.map { |p| p.join('=') }.join('&')
      end

      def for_post_body(params)
        @sorted_json ||= BuildPostBody.new(params).sorted_json
      end

      def build_request_message(params)
        request.request_method.upcase +
          request.path_info.downcase +
          request.host.downcase +
          params
      end

      def read_rack_input
        form_vars = request.env['rack.input'].read
        form_vars = ::JSON.parse(form_vars) rescue form_vars
        request.env['rack.input'].rewind
        form_vars
      end

    end
  end
end
