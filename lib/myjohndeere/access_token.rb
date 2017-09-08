module MyJohnDeere
  class AccessToken
    attr_accessor :oauth_token_access_token

    def self.oauth_consumer(options = {})
      OAuth::Consumer.new(
        MyJohnDeere.configuration.app_id, 
        MyJohnDeere.configuration.shared_secret,
        options.merge(
          site: MyJohnDeere.configuration.endpoint,
          header: {Accept: MyJohnDeere::JSON_CONTENT_HEADER_VALUE}
          ))
    end

    # Use this if you need to get the verifier code. You'll need to use this
    # along with the request_token.authorize_url to have the user sign in and
    # provide you with a verifier code
    def self.get_request_token()
      consumer = self.oauth_consumer(
        authorize_url: MyJohnDeere::AUTHORIZE_URL,
        http_method: :get
      )
      return consumer.get_request_token({})
    end

    def initialize(oauth_access_token)
        request_token = OAuth::RequestToken.from_hash(self.class.oauth_consumer, {oauth_token: self.token, oauth_token_secret: self.token_secret})
        @access_token = request_token.get_access_token(oauth_verifier: self.verifier)
      self.oauth_token_access_token = OAuth::AccessToken.from_hash(
        self.class.oauth_consumer, 
        {
          oauth_token: self.a_token, 
          oauth_token_secret: self.a_secret
        }
      )
    end
  end

end