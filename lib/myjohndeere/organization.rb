module MyJohnDeere
  class Organization < Requestable
    PATH = "organizations"
    attr_accessor :id, :name, :user_is_member, :type, :links

    def initialize(json_object, access_token = nil)
      self.id = json_object["id"]
      self.name = json_object["name"]
      # This will be either customer or dealer
      self.type = json_object["type"]
      self.user_is_member = json_object["member"]
      self.links = json_object["links"]
      super(access_token)
    end

    def self.retrieve(access_token, id)
      response = access_token.execute_request(:get, "#{PATH}/#{id}")

      return new(response.data, access_token)
    end
  end
end