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
      
      response = access_token.execute_request(:post, 
        build_resouce_base_path!(self.list_resource_path, {map_layer_id: map_layer_id}),
        body: body
      )
      #{"Content-Type"=>"text/plain", "X-Deere-Handling-Server"=>"ldxtc3", "X-Frame-Options"=>"SAMEORIGIN", "Location"=>"https://sandboxapi.deere.com/platform/mapLayers/e2711205-c5df-445e-aad5-81eaf9090e6c", "X-Deere-Elapsed-Ms"=>"162", "Vary"=>"Accept-Encoding", "Expires"=>"Thu, 14 Sep 2017 15:52:24 GMT", "Cache-Control"=>"max-age=0, no-cache", "Pragma"=>"no-cache", "Date"=>"Thu, 14 Sep 2017 15:52:24 GMT", "Transfer-Encoding"=>"chunked", "Connection"=>"close, Transfer-Encoding"}
      id = get_created_id_from_response_headers(self.base_jd_resource, response)
      if id.nil? then
        return nil
      else
        return self.new({"id" => id}.merge(body).stringify_keys)
      end
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