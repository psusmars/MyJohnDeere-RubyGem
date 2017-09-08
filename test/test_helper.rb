require 'minitest/autorun'
require 'myjohndeere'
require 'byebug'
require 'webmock/minitest'

PROJECT_ROOT = File.expand_path("../../", __FILE__)
#require File.expand_path('../api_fixtures', __FILE__)

class Minitest::Test
  # Fixtures are available in tests using something like:
  #
  #   API_FIXTURES[:fields][:id]
  #
  # API_FIXTURES = APIFixtures.new

  def teardown
    WebMock.reset!
  end
end