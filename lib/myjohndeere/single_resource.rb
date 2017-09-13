module MyJohnDeere
  class SingleResource < Requestable
    include RESTMethods
    include JSONAttributes
    attr_accessor :deleted

    def initialize(json_object, access_token = nil)
      super(json_object, access_token)
      setup_attributes(json_object)
      self.deleted = self.links.any? { |link_hash| link_hash["rel"] == "delete" }
    end
  end
end