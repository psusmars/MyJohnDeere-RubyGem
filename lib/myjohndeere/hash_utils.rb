module MyJohnDeere
  class HashUtils
    def self.transform_hash(original, options={}, &block)
      original.inject({}){|result, (key,value)|
        value = if (options[:deep] && Hash === value) 
                  transform_hash(value, options, &block)
                else 
                  if Array === value
                    value.map{|v| transform_hash(v, options, &block)}
                  else
                    value
                  end
                end
        block.call(result,key,value)
        result
      }
    end

    # Convert keys to strings
    def self.stringify_keys(in_hash)
      transform_hash(in_hash) {|hash, key, value|
        hash[key.to_s] = value
      }
    end

    # Convert keys to strings, recursively
    def self.deep_stringify_keys(in_hash)
      transform_hash(in_hash, :deep => true) {|hash, key, value|
        hash[key.to_s] = value
      }
    end
  end
end