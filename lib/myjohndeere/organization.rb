module MyJohnDeere
  class Organization < SingleResource
    self.base_jd_resource = "organizations"
    self.list_resource_path = self.base_jd_resource
    self.retrieve_resource_path = self.base_jd_resource
    attributes_to_pull_from_json(:id, :name, :type, :member)

    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
    end

    def has_access_to_boundaries?
      self.has_access_to?("boundaries")
    end

    def has_access_to_fields?
      self.has_access_to?("fields")
    end

    def fields
      return MyJohnDeere::Field.list(self.access_token, organization_id: self.id)
    end
  end
end