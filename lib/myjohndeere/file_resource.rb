module MyJohnDeere
  class FileResource < OrganizationOwnedResource
    self.base_jd_resource = "fileResources"
    self.list_resource_path = "mapLayers/%{map_layer_id}/#{self.base_jd_resource}"
    self.retrieve_resource_path = self.base_jd_resource
    attributes_to_pull_from_json(:id, :filename, :mimeType, :metadata, :timestamp)

    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
    end

    def self.create(access_token, organization_id, map_layer_id, file_type: nil,
        metadata: [])
      raise ArgumentError.new("You must pass a file_type") if file_type.nil?
      raise ArgumentError.new("You must pass a valid organization id") if organization_id.nil?
      raise ArgumentError.new("You must pass a valid map layer id") if map_layer_id.nil?

      case file_type
      when :png
        mime_type = 'image/png'
      when :zip
        mime_type = 'application/zip'
      else
        raise ArgumentError.new("You must specify either a zip or a png")
      end

      body = {
        links: [
            self.owning_organization_link_item(organization_id)
        ],
        mimeType: mime_type,
        metadata: metadata.map { |m| m.to_hash }
      }
      
      return send_create(access_token, body, {map_layer_id: map_layer_id})
    end

    def self.upload_file(access_token, file_resource_id, file_path)
      File.open(file_path, "rb:UTF-8") do |f|
          body = f.read()
          response = access_token.execute_request(:put,
            "#{self.base_jd_resource}/#{file_resource_id}",
            body: body,
            headers: { 
              'accept'=> 'application/vnd.deere.axiom.v3+json',
              "Content-Type"=>'application/octet-stream' ,
              "Content-Length" => body.bytesize.to_s
            })
          return response.code == 204
      end
    end
  end
end