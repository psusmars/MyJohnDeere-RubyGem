require 'net/http'
require 'json'
require 'rbconfig'
require 'base64'

# Version
require 'myjohndeere/version'

# API Support Classes
require 'myjohndeere/access_token'

module MyJohnDeere
  JSON_CONTENT_HEADER_VALUE = 'application/vnd.deere.axiom.v3+json'
  AUTHORIZE_URL = "https://my.deere.com/consentToUseOfData"
  DEFAULT_REQUEST_HEADER = { 'accept'=> JSON_CONTENT_HEADER_VALUE }
  DEFAULT_POST_HEADER = { 
    'accept'=> JSON_CONTENT_HEADER_VALUE,
    "Content-Type"=> JSON_CONTENT_HEADER_VALUE
  }
  ETAG_HEADER_KEY = "x-deere-signature"

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :endpoint
    attr_writer :shared_secret, :app_id

    def initialize
      # Assume the sandbox endpoint
      @endpoint = "https://sandboxapi.deere.com/platform"
      # Production would be https://api.soa-proxy.deere.com/platform
      @shared_secret = nil
      @app_id = nil
    end

    def shared_secret
      if @shared_secret.nil? then
        raise 
      end
    end
  end
end