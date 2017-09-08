require File.expand_path('../test_helper', __FILE__)

class TestMyJohnDeere < Minitest::Test
  def test_uninitialized_configuration
    MyJohnDeere.configuration = MyJohnDeere::Configuration.new
    assert_raises MyJohnDeere::ConfigurationError do
      MyJohnDeere.configuration.app_id
    end

    assert_raises MyJohnDeere::ConfigurationError do
      MyJohnDeere.configuration.shared_secret
    end
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
end