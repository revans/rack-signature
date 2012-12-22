# class Hash
#   def deep_sort
#     Hash[
#       sort.map { |k, v| 
#         if v.is_a?(Hash)
#           [k, v.deep_sort]
#         elsif v.is_a?(Array) && v.first.is_a?(Hash)
#           [k, v.deep_sort]
#         else
#           [k, v]
#         end
#       }
#     ]
#   end
# end

# class Array
#   def deep_sort
#     sort.map do |v|
#       if v.is_a?(Array)
#         v.deep_sort
#       elsif v.is_a?(Hash)
#         v.deep_sort
#       else
#         v
#       end
#     end
#   end
# end


module Rack
  module Signature
    class SortQueryParams
      attr_reader :query_params
      def initialize(query)
        @query_params = query
      end

      def order
        deep_sort(query_params)
      end

      def deep_sort(hash)
        Hash[hash.sort.map { |key, value|
          if value.is_a?(Hash)
            [key, deep_sort(value)]
          elsif value.is_a?(Array) && value.first.is_a?(Hash)
            [key, deep_array_sort(value)]
          else
            [key, value]
          end
        }]
      end

      def deep_array_sort(array)
        array.sort.map do |value|
          if value.is_a?(Array)
            deep_array_sort(value)
          elsif value.is_a?(Hash)
            deep_sort(value)
          else
            value
          end
        end
      end

    end
  end
end
