module MyJohnDeere 
  module RESTMethods
    module ClassMethods
      attr_accessor :supports_delete
      attr_accessor :base_jd_resource
      attr_accessor :retrieve_resource_path
      attr_accessor :list_resource_path
      # If the resource requires a base resource, specify it in the format of:
      # <resource_singular_name_id>: <ID>
      def list(access_token, options = {})
        validate_access_token(access_token)
        options = {count: 10, start: 0, etag: nil}.merge(options)
        if !options[:etag].nil? then
          options.delete(:count)
          options.delete(:start)
        end
        options[:body] ||= {}
        # The count and start are in this list,so move them into the body
        SPECIAL_BODY_PARAMETERS.each do |sbp|
          next if options[sbp].nil?
          options[:body][sbp] = options[sbp]
        end

        response = access_token.execute_request(:get, build_resource_base_path!(self.list_resource_path, options), 
          options
        )
        return ListObject.new(
          self,
          access_token,
          response.data,
          response.code,
          options: options.merge(
            etag: response.http_headers[MyJohnDeere::ETAG_HEADER_KEY]
          )
        )
      end

      def retrieve(access_token, id, options={})
        validate_access_token(access_token)
        response = access_token.execute_request(:get, 
          "#{build_resource_base_path!(self.retrieve_resource_path, options)}/#{id}",
          options)

        return new(response.data, access_token)
      end

      def delete(access_token, id)
        raise UnsupportedRequestError.new("Delete is not supported by this resource") if !self.supports_delete

        response = access_token.execute_request(:delete, "#{self.base_jd_resource}/#{id}")
        return response.code == 204
      end

      def build_resource_base_path!(resource_path, options = {})
        expected_definitions = resource_path.scan(/%{(.+?)}/)
        return resource_path if expected_definitions.empty?
        base_resources = {}
        options.each do |key, val|
          base_resources[key] = options.delete(key) if key.match(/_id\Z/)
        end
        MyJohnDeere.logger.info("Building resource path: #{resource_path}, with ids: #{base_resources}")
        begin 
          return resource_path % base_resources
        rescue KeyError
          raise ArgumentError.new("You must specify #{expected_definitions.join(", ")} as part of this request path")
        end
      end

      def validate_access_token(access_token)
        raise ArgumentError.new("The first argument must be an #{AccessToken}") if !access_token.is_a?(AccessToken)
      end

      def send_create(access_token, body, path_builder_options = {})
        response = access_token.execute_request(:post, 
          build_resource_base_path!(self.list_resource_path, path_builder_options),
          body: body
        )
        #{"Content-Type"=>"text/plain", "X-Deere-Handling-Server"=>"ldxtc3", "X-Frame-Options"=>"SAMEORIGIN", "Location"=>"https://sandboxapi.deere.com/platform/mapLayers/e2711205-c5df-445e-aad5-81eaf9090e6c", "X-Deere-Elapsed-Ms"=>"162", "Vary"=>"Accept-Encoding", "Expires"=>"Thu, 14 Sep 2017 15:52:24 GMT", "Cache-Control"=>"max-age=0, no-cache", "Pragma"=>"no-cache", "Date"=>"Thu, 14 Sep 2017 15:52:24 GMT", "Transfer-Encoding"=>"chunked", "Connection"=>"close, Transfer-Encoding"}
        id = get_created_id_from_response_headers(self.base_jd_resource, response)
        if id.nil? then
          return nil
        else
          return self.new(HashUtils.deep_stringify_keys({"id" => id}.merge(body)))
        end
      end
    end
     
    module InstanceMethods
       
    end
     
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end