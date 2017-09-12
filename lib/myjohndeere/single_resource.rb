module MyJohnDeere
  class SingleResource < Requestable
    attr_accessor :id, :name, :links, :deleted

    def initialize(json_object, access_token = nil)
      super(access_token)

      self.id = json_object["id"]
      self.name = json_object["name"]
      self.links = json_object["links"] || []
      self.deleted = self.links.any? { |link_hash| link_hash["rel"] == "delete" }
    end
  end
end