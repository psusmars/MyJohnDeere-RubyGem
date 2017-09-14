module MyJohnDeere
  class MapLegendItem < APISupportItem
    attributes_to_pull_from_json(:label, :minimum, :maximum, :hexColor, :percent)
    
    # see attributes_to_pull_from_json for the order if creating yourself
    def initialize(*args)
      super(args)
    end
  end
end