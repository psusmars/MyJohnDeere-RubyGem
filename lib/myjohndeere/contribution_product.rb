module MyJohnDeere
  class ContributionProduct < SingleResource
    self.base_jd_resource = "contributionProducts"
    self.list_resource_path = self.base_jd_resource
    self.retrieve_resource_path = self.base_jd_resource
    attributes_to_pull_from_json(:id, :marketPlaceName, :marketPlaceDescription, 
      :marketPlaceLogo, :defaultLocale, :currentStatus, :authenticationCallback,
      :activationCallback, :previewImages, :supportedLocales, :supportedRegions,
      :supportedOperationCenters)

    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
    end
  end
end