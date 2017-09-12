module MyJohnDeere
  class Field < SingleResource
    self.resource_base_path = "organizations/%{organization_id}/fields"
    attr_accessor :organization_id

    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
      owning_organization_link = self.links.detect { |l| l["rel"] == "owningOrganization" } 
      if owning_organization_link then
        self.organization_id = /\/(\d+)\Z/.match(owning_organization_link["uri"])[1]
      end
    end
  end
end