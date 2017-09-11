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

    def send_request(method, path, options = {})
      path = "/#{path}" if not path.start_with?("/")
      options = {
        body: "",
        etag: nil
      }.merge(options)
      if method == :post || method == :put then
        options[:headers] ||= MyJohnDeere::DEFAULT_POST_HEADER
        options[:headers]["Content-Length"] ||= options[:body].length.to_s
      else
        options[:headers] ||= MyJohnDeere::DEFAULT_REQUEST_HEADER
      end
      if !options[:etag].nil? then
        # Pass an empty string to have it start
        options[:headers][MyJohnDeere::ETAG_HEADER_KEY] = options[:etag]
      end
      response = nil
      # in the case of following one of their paths, just clear out the base
      path = path.sub(MyJohnDeere.configuration.endpoint, '')

      # always trim platform from the beginning as we have that in our base
      path = path.sub(/\A\/platform/, "")

      if [:get, :delete, :head].include?(method)
        # we'll only accept hashes for the body for now
        if options[:body].is_a?(Hash)
          uri = URI.parse(path)
          new_query_ar = URI.decode_www_form(uri.query || '')
          options[:body].each do |key, val|
            new_query_ar << [key.to_s, val.to_s]
          end
          uri.query = URI.encode_www_form(new_query_ar)
          path = uri.to_s
        end
        response = self.oauth_access_token.send(method, path, options[:headers])
      else
        # permit the body through
        response = self.oauth_access_token.send(method, path, options[:body], options[:headers])
      end
      MyJohnDeere.log.info("JohnDeere token response: #{response.body}")
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