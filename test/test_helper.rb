require 'minitest/autorun'
require 'myjohndeere'
require 'byebug'
require 'webmock/minitest'

PROJECT_ROOT = File.expand_path("../../", __FILE__)
require File.expand_path('../api_fixtures', __FILE__)

class Minitest::Test
  # Fixtures are available in tests using something like:
  #
  #   API_FIXTURES[:fields][:id]
  #
  API_FIXTURES = APIFixtures.new

  def setup
    MyJohnDeere.configure do |config|
      config.app_id = "Dontcare"
      config.shared_secret = "somesecret"
      config.environment = :sandbox
      #config.log_level = :info
    end
  end

  def teardown
    WebMock.reset!
  end

  def default_access_token
    MyJohnDeere::AccessToken.new(
      oauth_access_token_token: "1Of2eWDVM2x90j1kjxVgxlz091kjmnndsa0912FYwz7ZxlVgPcPmFGb1RtBWLXGVw3k",
      oauth_access_token_secret: "2f05ab26-1879-4bfe-9129-b9b0144d1610",
    )
  end
end