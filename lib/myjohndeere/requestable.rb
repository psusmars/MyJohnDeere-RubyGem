module MyJohnDeere
  class Requestable
    attr_accessor :access_token, :links

    def initialize(json_object = {}, access_token = nil)
      self.links = json_object["links"] || []
      self.access_token = access_token
      approved_class = MyJohnDeere::AccessToken
      if !self.access_token.nil? && !self.access_token.is_a?(approved_class) then
        raise ArgumentError.new("Expected a #{approved_class}, do not know how to handle #{self.access_token.class}")
      end
    end

    def extract_link_with_rel_from_list(rel_target, regex_to_capture_item)
      link = self.links.detect { |l| l["rel"] == rel_target }
      if link then
        return regex_to_capture_item.match(link["uri"])[1]
      else
        return nil
      end
    end
  end
end