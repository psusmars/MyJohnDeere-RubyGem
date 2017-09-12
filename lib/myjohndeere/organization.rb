module MyJohnDeere
  class Organization < Requestable
    PATH = "organizations"
    attr_accessor :id, :name, :user_is_member, :type, :links, :deleted

    def initialize(json_object, access_token = nil)
      self.id = json_object["id"]
      self.name = json_object["name"]
      # This will be either customer or dealer
      self.type = json_object["type"]
      self.user_is_member = json_object["member"]
      self.links = json_object["links"]
      self.deleted = self.links.any? { |link_hash| link_hash["rel"] == "delete" }
      super(access_token)
    end

    def self.retrieve(access_token, id)
      response = access_token.execute_request(:get, "#{PATH}/#{id}")

      return new(response.data, access_token)
    end

    def self.list(access_token, count: 10, start: 0, etag: "")
      response = access_token.execute_request(:get, "#{PATH}", 
        body: {start: start, count: count},
        etag: etag
      )

      return_data = response.data["values"]
      return ListObject.new(
        self,
        access_token,
        return_data.collect { |i| Organization.new(i, access_token) },
        total: response.data["total"],
        count: count,
        start: start,
        etag: response.http_headers[MyJohnDeere::ETAG_HEADER_KEY])
    end
  end
end