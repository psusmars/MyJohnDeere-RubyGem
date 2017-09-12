require File.expand_path('../test_helper', __FILE__)

class TestRestMethods < Minitest::Test
  def test_argument_validation_on_list()
    assert_raises ArgumentError do
      MyJohnDeere::Organization.list(nil, count: 1)
    end
  end

  def test_argument_validation_on_retrieve
    assert_raises ArgumentError do
      MyJohnDeere::Organization.retrieve(nil, 1234)
    end
  end
end