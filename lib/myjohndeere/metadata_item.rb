module MyJohnDeere
  class MetadataItem < APISupportItem
    attributes_to_pull_from_json(:key, :value)
    def initialize(*args)
      super(args)
    end
  end
end