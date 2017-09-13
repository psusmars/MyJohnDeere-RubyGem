module MyJohnDeere
  class Organization < SingleResource
    self.base_jd_resource = "organizations"
    self.list_resource_path = self.base_jd_resource
    self.retrieve_resource_path = self.base_jd_resource
    attr_accessor :user_is_member, :type, :deleted

    def initialize(json_object, access_token = nil)
      # This will be either customer or dealer
      self.type = json_object["type"]
      self.user_is_member = json_object["member"]
      super(json_object, access_token)
    end

    def fields
      return MyJohnDeere::Field.list(self.access_token, organization_id: self.id)
    end
  end
end