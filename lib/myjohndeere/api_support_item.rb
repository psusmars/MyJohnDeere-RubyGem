module MyJohnDeere
  class APISupportItem
    include JSONAttributes
    # see attributes_to_pull_from_json for the order if creating yourself
    def initialize(args)
      if args.length == 1 then
        # assume the json object was passed
        setup_attributes(args[0])
      else
        # otherwise assume normal construction according to the order for the json attributes 
        self.class.json_attributes.each_with_index do |attribute, i|
          underscored = attribute.to_s.underscore
          raise ArgumentError("You must pass #{attribute} as argument #{i+1}") if self.class.json_attributes.length <= i 
          self.send("#{underscored}=", args[i])
        end
      end
    end

    def to_hash()
      ret_hash = {}
      self.class.json_attributes.each do |attrib|
        ret_hash[attrib] = self.send(attrib.to_s.underscore)
      end
      return ret_hash
    end
  end
end