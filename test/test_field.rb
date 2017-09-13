require File.expand_path('../test_helper', __FILE__)

class TestField < Minitest::Test
  FIXTURE = API_FIXTURES.fetch("field")
  FIXTURE_FOR_LIST = API_FIXTURES.fetch("fields")
  ORGANIZATION_FIXTURE = API_FIXTURES["organization"]

  def test_retrieve()
    expected_organization_id = ORGANIZATION_FIXTURE["id"]
    expected_field_id = FIXTURE["id"]
    stub_request(:get, /\/organizations\/#{expected_organization_id}\/fields\/#{expected_field_id}/).
      to_return(status: 200, body: FIXTURE.to_json)

    field = MyJohnDeere::Field.retrieve(default_access_token, 
      expected_field_id, organization_id: expected_organization_id)

    assert_equal expected_field_id, field.id
    assert_equal expected_organization_id, field.organization_id
    assert_equal "Nautilus", field.name
    assert_equal FIXTURE["links"].length, field.links.length
  end

  def test_retrieve_with_embedded_boudnary
    fixture = API_FIXTURES["field_with_embedded_boundary"]
    stub_request(:get, /\/organizations\/#{ORGANIZATION_FIXTURE["id"]}\/fields\/#{fixture["id"]}/).
      with(query: {embed: "boundaries"}).
      to_return(status: 200, body: fixture.to_json)

    field = MyJohnDeere::Field.retrieve(default_access_token, 
      fixture["id"], organization_id: ORGANIZATION_FIXTURE["id"],
      body: {embed: "boundaries"})

    assert field.instance_variable_get(:@boundary)
    assert_equal fixture["boundaries"][0]["id"], field.boundary.id
    assert_equal field.id, field.boundary.field_id
  end

  def test_list()
    stub_request(:get, /organizations\/#{ORGANIZATION_FIXTURE["id"]}\/fields/).
      to_return(status: 200, body: FIXTURE_FOR_LIST.to_json)

    fields = MyJohnDeere::Field.list(default_access_token, count: 1, organization_id: ORGANIZATION_FIXTURE["id"])

    assert_equal 1, fields.data.length
    assert_equal MyJohnDeere::Field, fields.data[0].class
  end
end