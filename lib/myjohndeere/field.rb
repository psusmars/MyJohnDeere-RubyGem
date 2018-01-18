module MyJohnDeere
  class Field < OrganizationOwnedResource
    self.base_jd_resource = "fields"
    self.list_resource_path = "organizations/%{organization_id}/#{self.base_jd_resource}"
    self.retrieve_resource_path = "organizations/%{organization_id}/#{self.base_jd_resource}"
    attributes_to_pull_from_json(:id, :name, :boundaries)

    def initialize(json_object, access_token = nil)
      @boundary = nil
      super(json_object, access_token)
      boundaries = json_object["boundaries"]
      if boundaries && boundaries.length > 0 then
        # If we embed, then we'll need to pass our id
        possible_boundaries = boundaries.map { |b_json| Boundary.new(b_json, access_token, self.id) }
        self.boundary = possible_boundaries.find { |b| b.active && !b.deleted }
        # Fallback to the first one then
        self.boundary ||= possible_boundaries.first
      end
    end

    # Will return whether or not the boundary has been set,
    # useful if you're expecting embedded boundaries
    def boundary_unset?
      return @boundary.nil?
    end

    def boundary
      if self.boundary_unset? then
        @boundary = Boundary.retrieve(self.access_token, field_id: self.id, organization_id: self.organization_id)
      end
      return @boundary
    end

    def boundary=(val)
      @boundary = val
    end
  end
end