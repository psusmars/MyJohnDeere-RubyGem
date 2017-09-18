module MyJohnDeere
  # MyJohnDeereError is the base error from which all other more specific MyJohnError
  # errors derive.
  class MyJohnDeereError < StandardError
    attr_reader :message

    # These fields are now available as part of #response and that usage should
    # be preferred.
    attr_reader :http_body
    attr_reader :http_headers
    attr_reader :http_status

    attr_accessor :response
    # Initializes a MyJohnDeereError.
    def initialize(message=nil, http_status: nil, http_body: nil,
                   http_headers: nil, my_john_deere_response: nil)
      @message = message
      if my_john_deere_response.is_a?(MyJohnDeere::Response) then
        self.response = my_john_deere_response
        http_status = my_john_deere_response.http_status
        http_body = my_john_deere_response.http_body
        http_headers = my_john_deere_response.http_headers
      end
      @http_status = http_status
      @http_body = http_body
      @http_headers = http_headers || {}
    end

    def to_s
      status_string = @http_status.nil? ? "" : "(Status #{@http_status}) "
      id_string = @request_id.nil? ? "" : "(Request #{@request_id}) "
      "#{status_string}#{id_string}#{@message}"
    end
  end

  # Configuration error is raised when configuration hasn't been properly done
  class ConfigurationError < MyJohnDeereError
  end

  # AuthenticationError is raised when invalid credentials are used to connect
  # to MyJohnDeere's servers or if your credentials have expired.
  class AuthenticationError < MyJohnDeereError
  end

  # Raised when accessing resources you don't have access to. Generally just need to
  # avoid making this request
  class PermissionError < MyJohnDeereError
  end

  # Raised when too many requests are being made
  class RateLimitError < MyJohnDeereError
  end

  # Raised when something goes wrong with MyJohnDeere API
  class InternalServerError < MyJohnDeereError
  end

  # Raised when the server is busy
  class ServerBusyError < MyJohnDeereError
  end
end