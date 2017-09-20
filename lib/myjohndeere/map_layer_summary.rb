module MyJohnDeere
  class MapLayerSummary < OrganizationOwnedResource
    self.supports_delete = true
    self.base_jd_resource = "mapLayerSummaries"
    self.list_resource_path = "organizations/%{organization_id}/fields/%{field_id}/#{self.base_jd_resource}"
    self.retrieve_resource_path = self.base_jd_resource
    attributes_to_pull_from_json(:id, :title, :text, :metadata, :dateCreated, :lastModifiedDate)

    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
    end

    def self.create(access_token, organization_id, field_id, 
        title, caption, metadata: [], date_created: nil)
      body = {
        title: title,
        text: caption,
        links: [
            owning_organization_link_item(organization_id),
            {
               rel: "contributionDefinition",
               uri: "#{MyJohnDeere.configuration.endpoint}/#{MyJohnDeere.configuration.contribution_definition_id}"
            }
         ],
        metadata: metadata.map { |md| md.to_hash },
        dateCreated: (date_created || Time.now).strftime("%Y-%m-%dT%H:%M:%S.%LZ")
      }
      
      return send_create(access_token, body, {field_id: field_id, organization_id: organization_id})
    end
  end
end