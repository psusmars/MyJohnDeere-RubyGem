module MyJohnDeere
  class MapLayer < OrganizationOwnedResource
    self.base_jd_resource = "mapLayers"
    self.list_resource_path = "mapLayerSummaries/%{map_layer_summary_id}/#{self.base_jd_resource}"
    self.retrieve_resource_path = self.base_jd_resource
    attributes_to_pull_from_json(:id, :title, :extent, :legends)

    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
      self.legends["ranges"].map! { |l| MapLegendItem.new(l) }
    end

    def self.create(access_token, map_layer_summary_id, organization_id,
        title: "", minimum_latitude: 0, maximum_latitude: 0, 
        minimum_longitude: 0, maximum_longitude:0, map_layer_id: "", map_legend_items: [])
      body = {
        links: [
          self.owning_organization_link_item(organization_id)
        ],
        title: title,
        extent: {
          minimumLatitude: minimum_latitude,
          maximumLatitude: maximum_latitude,
          minimumLongitude: minimum_longitude,
          maximumLongitude: maximum_longitude
        },
        legends: {
           unitId: map_layer_id,
           ranges: map_legend_items.map { |mls| mls.to_hash }
        }
      }

      response = access_token.execute_request(:post, 
        build_resouce_base_path!(self.list_resource_path, {map_layer_summary_id: map_layer_summary_id}),
        body: body
      )
      #{"Content-Type"=>"text/plain", "X-Deere-Handling-Server"=>"ldxtc3", "X-Frame-Options"=>"SAMEORIGIN", "Location"=>"https://sandboxapi.deere.com/platform/mapLayers/e2711205-c5df-445e-aad5-81eaf9090e6c", "X-Deere-Elapsed-Ms"=>"162", "Vary"=>"Accept-Encoding", "Expires"=>"Thu, 14 Sep 2017 15:52:24 GMT", "Cache-Control"=>"max-age=0, no-cache", "Pragma"=>"no-cache", "Date"=>"Thu, 14 Sep 2017 15:52:24 GMT", "Transfer-Encoding"=>"chunked", "Connection"=>"close, Transfer-Encoding"}
      id = get_created_id_from_response_headers(self.base_jd_resource, response)
      if id.nil? then
        return nil
      else
        return self.new(HashUtils.deep_stringify_keys({"id" => id}.merge(body)))
      end
    end
  end
end