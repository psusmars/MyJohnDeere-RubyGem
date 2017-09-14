class Hash
  def stringify_keys
    inject({}) do |hash, (key, value)|
      value = value.stringify_keys if value.is_a?(Hash)
      hash[key.to_s] = value
      hash
    end
  end
end