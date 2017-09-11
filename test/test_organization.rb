require File.expand_path('../test_helper', __FILE__)

class TestOrganization < Minitest::Test
  FIXTURE = API_FIXTURES.fetch(:organization)

  def test_retrieve()
    stub_request(:get, /organizations/).
      to_return(status: 200, body: FIXTURE.to_json)

    organization = MyJohnDeere::Organization.retrieve(default_access_token, FIXTURE[:id])

    assert_equal "1234", organization.id
    assert_equal "Smith Farms", organization.name
    assert_equal "customer", organization.type
    assert_equal true, organization.user_is_member
    assert organization.access_token
  end
end