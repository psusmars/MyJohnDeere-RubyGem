module MyJohnDeere
  class MapLayerSummary < OrganizationOwnedResource
    self.base_jd_resource = "mapLayerSummaries"
    self.list_resource_path = "organizations/%{organization_id}/fields/%{field_id}/#{self.base_jd_resource}"
    self.retrieve_resource_path = self.base_jd_resource
    attributes_to_pull_from_json(:id, :title, :text, :metadata, :dateCreated, :lastModifiedDate)

    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
    end

    # def self.create(access_token, organization_id, field_id, 
    #     title, caption, metadata = [], date_created=nil)
    #   response = access_token.execute_request(:post, 
    #     "/organizations/#{organization_id}/fields/#{field_id}/#{self.resource_base_path}/#{id}",
    #     body: {
    #       title: title,
    #       text: caption,
    #       links: [
    #           {
    #              rel: "owningOrganization",
    #              uri: "#{MyJohnDeere.configuration.endpoint}/organizations/#{organization_id}"
    #           },
    #           {
    #              rel: "contributionDefinition",
    #              uri: "#{MyJohnDeere.configuration.endpoint}/#{MyJohnDeere.configuration.contribution_definition_id}"
    #           }
    #        ],
    #       metadata: metadata,
    #       dateCreated: (date_created || Time.now).strftime("%Y-%m-%dT%H:%M:%S.%LZ")
    #     }
    #   )
    #   # "location"=>["https://sandboxapi.deere.com/platform/mapLayerSummaries/b161e522-c9ee-4170-b479-c34de6a40627"
    #   created_id = response.http_headers["location"]
    #   if !created_id.nil? then
    #     created_id = /#{resource_base_path}\/([^\/]+)\Z/.match(created_id)[1]
    #   else
    #     # didn't succeed
    #     MyJohnDeere.logger.info("Failed to create MapLayerSummary: #{response}")
    #   end
    #   return created_id
    # end
  end
end