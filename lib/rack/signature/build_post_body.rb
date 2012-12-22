require 'rack/request'
require 'json'
require_relative 'sort_query_params'

module Rack
  module Signature
    class BuildPostBody
      attr_reader :hash

      def initialize(hash)
        @hash = hash
      end

      def sorted_json
        sort_post_body.to_json
      end

      def sort_post_body
        SortQueryParams.new(parse_query).order
      end

      def parse_query
        ::Rack::Utils.parse_query(hash) rescue hash
      end

    end
  end
end
