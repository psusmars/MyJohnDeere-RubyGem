module MyJohnDeere
  class ContributionActivation < SingleResource
    self.base_jd_resource = "contributionActivations"
    self.list_resource_path = "organizations/%{organization_id}/#{self.base_jd_resource}"
    self.retrieve_resource_path = self.base_jd_resource
    attributes_to_pull_from_json(:activationStatus, :id)

    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
      if self.id.nil? then
        self.id = extract_link_with_rel_from_list("self", /contributionActivations\/([^\/]+)\Z/)
      end
    end

    def self.create(access_token, organization_id, contribution_product_id, activated: true)
      body = {
        # Must include the class
        "@type" => to_s.gsub(/^.*::/, ''),
        activationStatus: activated ? "ACTIVATED" : "DEACTIVATED",
        links: [
          {
            "@type" => "Link",
            rel: "ContributionProduct",
            uri: "#{MyJohnDeere.configuration.endpoint}/contributionProducts/#{contribution_product_id}"
          }
        ]
      }
      
      return send_create(access_token, body, organization_id: organization_id)
    end
  end
end