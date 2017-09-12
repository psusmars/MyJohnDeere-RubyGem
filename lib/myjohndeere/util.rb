module MyJohnDeere
  class Util
    def self.build_path_headers_and_body(method, path, headers: {}, body: "", etag: nil)
      # in the case of following one of their paths, just clear out the base
      path = path.sub(MyJohnDeere.configuration.endpoint, '')
      path = "/#{path}" if not path.start_with?("/")
      # always trim platform from the beginning as we have that in our base
      path = path.sub(/\A\/?platform/, "")

      default_headers = nil
      if method == :post || method == :put then
        body = body.to_json() if body.is_a?(Hash)
        default_headers = MyJohnDeere::DEFAULT_POST_HEADER
        content_length = body.length
        headers["Content-Length"] ||= body.length.to_s if content_length > 0
      else
        default_headers = MyJohnDeere::DEFAULT_REQUEST_HEADER
      end
      headers = default_headers.merge(headers || {})

      # we'll only accept hashes for the body for now
      if REQUEST_METHODS_TO_PUT_PARAMS_IN_URL.include?(method) && body.is_a?(Hash) then
        if !etag.nil? then
          # Pass an empty string to have it start
          headers[MyJohnDeere::ETAG_HEADER_KEY] = etag
        end
        uri = URI.parse(path)
        new_query_ar = URI.decode_www_form(uri.query || '')
        # For reasons beyond me, these are specified as non-parameters
        special_parameters = {
          start: body.delete(:start), 
          count: body.delete(:count)
        }
        body.each do |key, val|
          new_query_ar << [key.to_s, val.to_s]
        end
        special_parameters.each do |key,val|
          next if val.nil?
          query_string = "#{key}=#{val}"
          uri.path = "#{uri.path};#{query_string}" if !uri.path.include?(query_string)
        end
        uri.query = URI.encode_www_form(new_query_ar)
        path = uri.to_s
      end

      return path, headers, body
    end
  end
end