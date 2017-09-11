require File.expand_path('../test_helper', __FILE__)

class TestMyJohnDeere < Minitest::Test
  def test_uninitialized_configuration
    MyJohnDeere.configuration = MyJohnDeere::Configuration.new
    assert_raises MyJohnDeere::ConfigurationError do
      MyJohnDeere.configuration.app_id
    end
    MyJohnDeere.configuration.app_id = "blah"
    assert_equal "blah", MyJohnDeere.configuration.app_id

    assert_raises MyJohnDeere::ConfigurationError do
      MyJohnDeere.configuration.shared_secret
    end

    MyJohnDeere.configuration.shared_secret = "blah"
    assert_equal "blah", MyJohnDeere.configuration.shared_secret
  end

  def test_endpoint_setting
    MyJohnDeere.configuration = MyJohnDeere::Configuration.new
    assert_equal :sandbox, MyJohnDeere.configuration.environment
    assert_equal MyJohnDeere::ENDPOINTS[:sandbox], MyJohnDeere.configuration.endpoint

    assert_raises MyJohnDeere::ConfigurationError do
      MyJohnDeere.configuration.environment = :bar
    end

    MyJohnDeere.configuration.environment = "sandbox"
    assert_equal :sandbox, MyJohnDeere.configuration.environment
    assert_equal MyJohnDeere::ENDPOINTS[:sandbox], MyJohnDeere.configuration.endpoint

    MyJohnDeere.configuration.environment = :production
    assert_equal :production, MyJohnDeere.configuration.environment
    assert_equal MyJohnDeere::ENDPOINTS[:production], MyJohnDeere.configuration.endpoint
  end

  def test_logger_setup
    assert MyJohnDeere.log.is_a?(Logger)
    assert_equal Logger::FATAL, MyJohnDeere.log.level

    MyJohnDeere.configure do |config|
      config.log_level = :warn
    end

    assert_equal Logger::WARN, MyJohnDeere.log.level
  end
end