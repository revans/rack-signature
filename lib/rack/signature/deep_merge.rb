module Rack
  module Signature
    class DeepMerge
      def initialize(hash)
        @hash = hash
      end

      def merge!
        deep_merge(@hash).chomp('&')
      end

      # merge deep_merge & merge_hash
      def deep_merge(object, key = nil)
        object.each_with_object('') do |array, string|
          string << send_to_method( array, key )
        end
      end

      private

      def send_to_method(object, keys)
        key,values  = bind_variables(object, keys)
        continue_merge_or_complete(values, key)
      end

      def bind_variables(object, keys)
        if object.first.is_a?(String)
          key, values = build_key(keys, object.first), object.last
        else
          key, values = build_key(keys), object
        end
        [key,values]
      end

      def build_key(keys, keychain = nil)
        key   = keychain                  if keys.nil? || keys.empty? # root node
        key ||= hash_key(keys)            if keychain.nil?            # nested array
        key ||= hash_key(keys, keychain)  if keychain.is_a?(String)   # nested hash
        key
      end

      def hash_key(orig_key, key = nil)
        "#{orig_key}[#{key}]"
      end

      def continue_merge_or_complete(object, key)
        if object.is_a?(Hash) || object.is_a?(Array)
          deep_merge(object, key)
        else
          [key, object].join('=') << '&'
        end
      end

    end
  end
end
