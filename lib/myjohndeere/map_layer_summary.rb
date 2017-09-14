module MyJohnDeere
  class MapLayerSummary < OrganizationOwnedResource
    self.base_jd_resource = "mapLayerSummaries"
    self.list_resource_path = "organizations/%{organization_id}/fields/%{field_id}/#{self.base_jd_resource}"
    self.retrieve_resource_path = self.base_jd_resource
    attributes_to_pull_from_json(:id, :title, :text, :metadata, :dateCreated, :lastModifiedDate)

    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
    end

    def self.create(access_token, organization_id, field_id, 
        title, caption, metadata = [], date_created=nil)
      response = access_token.execute_request(:post, 
        build_resouce_base_path!(self.list_resource_path, {field_id: field_id, organization_id: organization_id}),
        body: {
          title: title,
          text: caption,
          links: [
              owning_organization_link_item(organization_id),
              {
                 rel: "contributionDefinition",
                 uri: "#{MyJohnDeere.configuration.endpoint}/#{MyJohnDeere.configuration.contribution_definition_id}"
              }
           ],
          metadata: metadata,
          dateCreated: (date_created || Time.now).strftime("%Y-%m-%dT%H:%M:%S.%LZ")
        }
      )
      # 201
      #{"Content-Type"=>"text/plain", "X-Deere-Handling-Server"=>"ldxtc4", "X-Frame-Options"=>"SAMEORIGIN", "Location"=>"https://sandboxapi.deere.com/platform/mapLayerSummaries/c5e9317e-eda6-48d3-acc8-c3bca3424858", "X-Deere-Elapsed-Ms"=>"362", "Vary"=>"Accept-Encoding", "Expires"=>"Wed, 13 Sep 2017 22:00:45 GMT", "Cache-Control"=>"max-age=0, no-cache", "Pragma"=>"no-cache", "Date"=>"Wed, 13 Sep 2017 22:00:45 GMT", "Transfer-Encoding"=>"chunked", "Connection"=>"close, Transfer-Encoding"}
      return get_created_id_from_response_headers(self.base_jd_resource, response)
    end
  end
end