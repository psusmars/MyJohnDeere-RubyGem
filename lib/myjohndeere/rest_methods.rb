module MyJohnDeere 
  module RESTMethods
    module ClassMethods
      attr_accessor :base_jd_resource
      attr_accessor :retrieve_resource_path
      attr_accessor :list_resource_path
      # If the resource requires a base resource, specify it in the format of:
      # <resource_singular_name_id>: <ID>
      def list(access_token, options = {})
        validate_access_token(access_token)
        options = {count: 10, start: 0, etag: nil}.merge(options)
        options[:body] ||= {}
        # The count and start are in this list,so move them into the body
        SPECIAL_BODY_PARAMETERS.each do |sbp|
          options[:body][sbp] = options[sbp]
        end

        response = access_token.execute_request(:get, build_resouce_base_path!(self.list_resource_path, options), 
          options
        )
        return_data = response.data["values"]
        return ListObject.new(
          self,
          access_token,
          return_data.collect { |i| self.new(i, access_token) },
          total: response.data["total"],
          options: options.merge(
            etag: response.http_headers[MyJohnDeere::ETAG_HEADER_KEY]
          )
        )
      end

      def retrieve(access_token, id, options={})
        validate_access_token(access_token)
        response = access_token.execute_request(:get, 
          "#{build_resouce_base_path!(self.retrieve_resource_path, options)}/#{id}",
          options)

        return new(response.data, access_token)
      end

      def build_resouce_base_path!(resource_path, options)
        base_resources = {}
        options.each do |key, val|
          base_resources[key] = options.delete(key) if key.match(/_id\Z/)
        end
        return resource_path if base_resources.nil? || base_resources.empty?
        MyJohnDeere.logger.info("Building resource path: #{resource_path}, with ids: #{base_resources}")
        return resource_path % base_resources
      end

      def validate_access_token(access_token)
        raise ArgumentError.new("The first argument must be an #{AccessToken}") if !access_token.is_a?(AccessToken)
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