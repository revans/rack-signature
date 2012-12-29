module Rack
  module Signature
    class SortQueryParams

      def initialize(object)
        @object = object
      end

      def order
        deep_sort(@object)
      end

      def deep_sort(object)
        if object.is_a?(Array)

          deep_array_sort(object)
        elsif object.is_a?(Hash)

          deep_hash_sort(object)
        else
          object
        end
      end

      def deep_hash_sort(object)
        return object unless object.is_a?(Hash)
        hash = Hash.new
        object.each         { |k,v| hash[k] = deep_sort(v) }
        sorted = hash.sort  { |a,b| a[0].to_s <=> b[0].to_s }
        hash.class[sorted]
      end

      def deep_array_sort(object)
        object.map do |value|
          if value.is_a?(Hash)
            deep_hash_sort(value)
          else
            value
          end
        end
      end

    end
  end
end
