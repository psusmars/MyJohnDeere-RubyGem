require File.expand_path('../test_helper', __FILE__)

class TestOrganization < Minitest::Test
  FIXTURE = API_FIXTURES.fetch("organization")
  FIXTURE_FOR_LIST = API_FIXTURES.fetch("organizations")

  def test_retrieve()
    stub_request(:get, /organizations/).
      to_return(status: 200, body: FIXTURE.to_json)

    organization = MyJohnDeere::Organization.retrieve(default_access_token, FIXTURE[:id])

    assert_equal "1234", organization.id
    assert_equal "Smith Farms", organization.name
    assert_equal "customer", organization.type
    assert_equal true, organization.user_is_member
    assert_equal FIXTURE["links"].length, organization.links.length
    assert organization.access_token
  end

  def test_list()
    stub_request(:get, /organizations;start=0;count=1/).
      to_return(status: 200, body: FIXTURE_FOR_LIST.to_json)

    organizations = MyJohnDeere::Organization.list(default_access_token, count: 1)

    assert_equal 1, organizations.data.length
    assert_equal MyJohnDeere::Organization, organizations.data[0].class
  end

  def test_fields()
    organization = MyJohnDeere::Organization.new(FIXTURE, default_access_token)

    stub_request(:get, /organizations\/#{organization.id}\/fields/).
      to_return(status: 200, body: API_FIXTURES["fields"].to_json)
    fields = organization.fields

    assert_equal MyJohnDeere::ListObject, fields.class
    assert_equal MyJohnDeere::Field, fields.data[0].class
  end
end