module MyJohnDeere
  class SingleResource < Requestable
    include RESTMethods
    attr_accessor :id, :name, :links, :deleted

    def initialize(json_object, access_token = nil)
      super(access_token)

      self.id = json_object["id"]
      self.name = json_object["name"]
      self.links = json_object["links"] || []
      self.deleted = self.links.any? { |link_hash| link_hash["rel"] == "delete" }
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