module MyJohnDeere
  class Requestable
    attr_accessor :access_token

    def initialize(access_token = nil)
      self.access_token = access_token
      approved_class = MyJohnDeere::AccessToken
      if !self.access_token.nil? && !self.access_token.is_a?(approved_class) then
        raise ArgumentError.new("Expected a #{approved_class}, do not know how to handle #{self.access_token.class}")
      end
    end
  end
end