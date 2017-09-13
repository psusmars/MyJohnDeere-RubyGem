module MyJohnDeere 
  module JSONAttributes
    module ClassMethods
      attr_accessor :json_attributes
      def attributes_to_pull_from_json(*attribs)
        self.json_attributes = attribs
        self.json_attributes.each do |attribute|
          attribute = attribute.to_s.underscore
          define_method("#{attribute}=") do |val|
            instance_variable_set("@#{attribute}", val)
          end
          define_method(attribute) do
            return instance_variable_get("@#{attribute}")
          end    
        end
      end
    end
    
    module InstanceMethods
      def setup_attributes(json_data)
        return if self.class.json_attributes.nil?
        self.class.json_attributes.each do |attrib|
          attrib = attrib.to_s
          val = json_data[attrib]
          if /date/i.match(attrib) then
            # try to parse it
            val = Time.parse(val) rescue val
          end
          instance_variable_set("@#{attrib.underscore}", val)
        end
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end