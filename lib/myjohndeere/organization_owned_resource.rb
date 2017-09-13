module MyJohnDeere
  class OrganizationOwnedResource < SingleResource
    attr_accessor :organization_id
    
    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
      self.organization_id = extract_link_with_rel_from_list("owningOrganization", /\/(\d+)\Z/)
    end
  end
end