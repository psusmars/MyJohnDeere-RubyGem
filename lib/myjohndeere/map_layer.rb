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

      return send_create(access_token, body, {map_layer_summary_id: map_layer_summary_id})
    end
  end
end