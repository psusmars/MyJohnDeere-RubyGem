module MyJohnDeere
  class File < OrganizationOwnedResource
    self.base_jd_resource = "files"
    self.list_resource_path = "organizations/%{organization_id}/#{self.base_jd_resource}"
    self.retrieve_resource_path = self.base_jd_resource
    attributes_to_pull_from_json(:id, :name, :type, :createdTime, :modifiedTime, :nativeSize, :source, :transferPending, :visibleViaShare, :shared, :status, :archived, :new)

    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
    end

    def upload_url()
      "#{MyJohnDeere.configuration.endpoint}/#{self.class.build_resource_base_path!("#{self.class.retrieve_resource_path}/#{self.id}")}"
    end

    def self.create(access_token, organization_id, name: nil)
      raise ArgumentError.new("You must pass a name for the file") if name.nil?

      body = {
        name: name
      }
      
      response = send_create(access_token, body, {organization_id: organization_id})

      return nil if response.nil?
      response.organization_id = organization_id
      return response
    end

    # TODO: Support upload_file
  end
end