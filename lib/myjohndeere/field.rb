module MyJohnDeere
  class Field < SingleResource
    attr_accessor :organization_id
    PATH = "organizations/%{o_id}/fields"

    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
      owning_organization_link = self.links.detect { |l| l["rel"] == "owningOrganization" } 
      if owning_organization_link then
        self.organization_id = /\/(\d+)\Z/.match(owning_organization_link["uri"])[1]
      end
    end

    def self.retrieve(access_token, organization_id, id)
      response = access_token.execute_request(:get, "#{PATH}/#{id}" % {o_id: organization_id})

      return new(response.data, access_token)
    end
  end
end