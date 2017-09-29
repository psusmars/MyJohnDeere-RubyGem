module MyJohnDeere
  class Requestable
    attr_accessor :access_token, :links

    def initialize(json_object = {}, access_token = nil)
      self.links = json_object["links"] || []
      self.access_token = access_token
      approved_class = MyJohnDeere::AccessToken
      if !self.access_token.nil? && !self.access_token.is_a?(approved_class) then
        raise ArgumentError.new("Expected a #{approved_class}, do not know how to handle #{self.access_token.class}")
      end
    end

    def has_access_to?(rel_link_name)
      self.links.any? {|i| i["rel"] == rel_link_name}
    end

    def extract_link_with_rel_from_list(rel_target, regex_to_capture_item)
      link = self.links.detect { |l| l["rel"] == rel_target }
      if link then
        return regex_to_capture_item.match(link["uri"])[1]
      else
        return nil
      end
    end

    def self.get_created_id_from_response_headers(resource, response)
      # 201 is the expected response code
      # The lowercase location shouldn't be needed but sometimes it is returned as lowercase...
      created_id = response.http_headers["Location"] || response.http_headers["location"]
      if !created_id.nil? then
        created_id = /#{resource}\/([^\/]+)\Z/.match(created_id)[1]
      else
        # didn't succeed
        MyJohnDeere.logger.info("Failed to create a #{resource}: #{response}")
        return nil
      end
    end
  end
end