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

    def token
      return oauth_access_token.nil? ? nil : oauth_access_token.token
    end

    def secret
      return oauth_access_token.nil? ? nil : oauth_access_token.secret
    end

    def execute_request(method, path, options = {})
      path, headers, body = Util.build_path_headers_and_body(method, path,
        headers: options[:headers],
        body: options[:body],
        etag: options[:etag])
      response =  nil
      MyJohnDeere.logger.debug("Sending request with body: #{body}\n headers: #{headers}")
      if REQUEST_METHODS_TO_PUT_PARAMS_IN_URL.include?(method)
        response = self.oauth_access_token.send(method, path, headers)
      else
        # permit the body through since it'll be in the 
        response = self.oauth_access_token.send(method, path, body, headers)
      end
      MyJohnDeere.logger.info("JohnDeere token response: #{response.body}")
      # if response.code == "401"
      #   self.notify_on_destroy = true
      #   # we are no longer authorized
      #   self.destroy
      #   logger.info("JohnDeere token destroyed: #{self.persisted?}, errors: #{self.errors.full_messages}")
      # end
      # return response
      return Response.new(response)
    end
  end
end