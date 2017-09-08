module MyJohnDeere
  class AccessToken
    attr_accessor :oauth_access_token

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
    # provide you with a verifier code. Makes a request to get the request_token.
    def self.get_request_token()
      consumer = self.oauth_consumer(
        authorize_url: MyJohnDeere::AUTHORIZE_URL,
        http_method: :get
      )
      return consumer.get_request_token({})
    end

    def initialize(options = {})
      request_token_options = [:request_token_token, :request_token_secret, :verifier_code]
      oauth_token_options = [:oauth_access_token_token, :oauth_access_token_secret]
      if request_token_options.all? { |i| options.key?(i) } then
        request_token = OAuth::RequestToken.from_hash(self.class.oauth_consumer, {
          oauth_token: options[:token],
          oauth_token_secret: options[:token_secret]
        })
        self.oauth_access_token = request_token.get_access_token(oauth_verifier: options[:verifier_code])
      elsif oauth_token_options.all? { |i| options.key?(i) } then
        self.oauth_access_token = OAuth::AccessToken.from_hash(
          self.class.oauth_consumer, 
          {
            oauth_token: options[:oauth_access_token_token],
            oauth_token_secret: options[:oauth_access_token_secret]
          }
        )
      else
        raise ArgumentError.new("You must specify either request token options [#{request_token_options.join(',')}] or [#{oauth_token_options.join(',')}]")
      end
    end
  end

end