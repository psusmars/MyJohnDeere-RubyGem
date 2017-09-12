module MyJohnDeere
  class Organization < SingleResource
    self.resource_base_path = "organizations"
    attr_accessor :user_is_member, :type, :deleted

    def initialize(json_object, access_token = nil)
      # This will be either customer or dealer
      self.type = json_object["type"]
      self.user_is_member = json_object["member"]
      super(json_object, access_token)
    end

  end
end