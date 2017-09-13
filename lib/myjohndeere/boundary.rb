module MyJohnDeere
  class Boundary < OrganizationOwnedResource
    self.base_jd_resource = "boundaries"
    self.list_resource_path = "organizations/%{organization_id}/fields/%{field_id}/#{self.base_jd_resource}"
    self.retrieve_resource_path = "organizations/%{organization_id}/#{self.base_jd_resource}"
    attributes_to_pull_from_json(:id, :name, :multipolygons, :active)
    attr_accessor :field_id

    def initialize(json_object, access_token = nil, field_id = nil)
      super(json_object, access_token)
      self.field_id = field_id
      self.active = self.active.to_s.downcase == "true"
      self.multipolygons = json_object["multipolygons"]
      # This doesn't exist currently, not sure why
      self.field_id ||= extract_link_with_rel_from_list("fields", /\/(\d+)\/(.+?)\/fields\Z/)
    end
  end
end