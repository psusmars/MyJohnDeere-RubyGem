require 'net/http'
require 'json'
require 'rbconfig'
require 'base64'
require 'oauth'
require 'logger'

# Core extensions
require 'myjohndeere/core_ext/string'

# Errors
require 'myjohndeere/errors'

# Version
require 'myjohndeere/version'

# API Support Classes
require 'myjohndeere/rest_methods'
require 'myjohndeere/json_attributes'
require 'myjohndeere/requestable'
require 'myjohndeere/util'
require 'myjohndeere/hash_utils'
require 'myjohndeere/response'
require 'myjohndeere/access_token'
require 'myjohndeere/list_object'
require 'myjohndeere/single_resource'
require 'myjohndeere/organization_owned_resource'
require 'myjohndeere/api_support_item'
require 'myjohndeere/contribution_activation'
require 'myjohndeere/contribution_product'

# API Sub-classes
require 'myjohndeere/map_legend_item'
require 'myjohndeere/metadata_item'

# API Objects
require 'myjohndeere/organization'
require 'myjohndeere/field'
require 'myjohndeere/boundary'
require 'myjohndeere/map_layer_summary'
require 'myjohndeere/map_layer'
require 'myjohndeere/file_resource'

module MyJohnDeere
  class << self
    attr_accessor :configuration
    def set_logger()
      @logger ||= Logger.new(STDOUT)
      @logger.level = Logger.const_get(self.configuration.log_level.to_s.upcase)
    end

    def logger
      if @logger.nil? then
        set_logger()
      end
      @logger
    end
  end

  JSON_CONTENT_HEADER_VALUE = 'application/vnd.deere.axiom.v3+json'
  ENDPOINTS = {
    sandbox: "https://sandboxapi.deere.com/platform",
    production: "https://api.soa-proxy.deere.com/platform"
  }.freeze
  AUTHORIZE_URL = "https://my.deere.com/consentToUseOfData"
  DEFAULT_REQUEST_HEADER = { 'accept'=> JSON_CONTENT_HEADER_VALUE }.freeze
  DEFAULT_POST_HEADER = { 
    'accept'=> JSON_CONTENT_HEADER_VALUE,
    "Content-Type"=> JSON_CONTENT_HEADER_VALUE
  }.freeze
  ETAG_HEADER_KEY = "X-Deere-Signature"
  REQUEST_METHODS_TO_PUT_PARAMS_IN_URL = [:get, :delete, :head]
  SPECIAL_BODY_PARAMETERS = [:start, :count]

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
    set_logger()
  end

  class Configuration
    attr_accessor :endpoint
    attr_writer :shared_secret, :app_id, :contribution_definition_id
    attr_reader :environment

    def log_level=(val)
      @log_level = val
    end

    def log_level
      @log_level ||= :fatal
      return @log_level
    end

    def environment=(val)
      @environment = val.to_sym
      @endpoint = ENDPOINTS[@environment]
      if @endpoint.nil?
        raise ConfigurationError.new('Invalid environment, you must use either :sandbox or :production. Sandbox is the default')
      end
    end

    def initialize
      # Assume the sandbox endpoint
      self.environment = :sandbox
      @shared_secret = nil
      @app_id = nil
    end

    def contribution_definition_id
      if @contribution_definition_id.nil? then
        raise ConfigurationError.new('No contribution_definition_id provided in configuration. ' \
          'Please set this to make the request, you\'ll need to contact JohnDeere support to get this value.')
      end
      return @contribution_definition_id
    end

    def shared_secret
      if @shared_secret.nil? then
        raise ConfigurationError.new('No shared_secret provided in configuration. ' \
          'Please set this according to your Deere Developer app credentials.')
      end
      return @shared_secret
    end

    def app_id
      if @app_id.nil? then
        raise ConfigurationError.new('No app_id provided in configuration. ' \
          'Please set this according to your Deere Developer app credentials.')
      end
      return @app_id
    end
  end
end