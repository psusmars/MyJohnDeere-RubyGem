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
        self.boundary = find_first_active_boundary(possible_boundaries)
      end
    end

    # Will return whether or not the boundary has been set,
    # useful if you're expecting embedded boundaries
    def boundary_unset?
      return @boundary.nil?
    end

    def boundary
      if self.boundary_unset? then
        boundaries = Boundary.list(self.access_token, field_id: self.id, organization_id: self.organization_id)
        @boundary = find_first_active_boundary(boundaries.data)
      end
      return @boundary
    end

    def boundary=(val)
      @boundary = val
    end

    private
      def find_first_active_boundary(possible_boundaries)
        active_boundaries = possible_boundaries.select { |b| b.active && !b.deleted }
        if active_boundaries.count > 1 then
          raise MyJohnDeereError.new("There was more than one boundary in the field, this is currently unexpected")
        elsif active_boundaries.count == 1 then
          return active_boundaries.first
        else
          return possible_boundaries.first
        end
      end
  end
end