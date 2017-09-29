require File.expand_path('../test_helper', __FILE__)

class TestAccessToken < Minitest::Test
  def test_initialization
    assert MyJohnDeere::Requestable.new()

    expected_object = default_access_token()
    requestable = MyJohnDeere::Requestable.new({}, expected_object)
    assert_equal expected_object, requestable.access_token

    assert_raises ArgumentError do
      MyJohnDeere::Requestable.new({}, "something")
    end
  end

  def test_has_access_to
    r = MyJohnDeere::Requestable.new({"links" => [
    {
     "rel" => "addresses",
     "uri" => "https://sandboxapi.deere.com/platform/organizations/1234/addresses"
    }]})

    assert r.has_access_to?("addresses")
    assert !r.has_access_to?("something_else")
  end
end