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

  def test_boundary_unset
    field = MyJohnDeere::Field.new({})
    assert field.boundary_unset?
    field.boundary = MyJohnDeere::Boundary.new({}, nil, 1)
    assert !field.boundary_unset?
  end

  def test_retrieval_with_multiple_boundaries
    fixture = API_FIXTURES["field_with_multiple_boundaries"]

    stub_request(:get, /\/organizations\/#{ORGANIZATION_FIXTURE["id"]}\/fields\/#{fixture["id"]}/).
      with(query: {embed: "boundaries"}).
      to_return(status: 200, body: fixture.to_json)

    field = MyJohnDeere::Field.retrieve(default_access_token, 
      fixture["id"], organization_id: ORGANIZATION_FIXTURE["id"],
      body: {embed: "boundaries"})

    assert_equal fixture["boundaries"][1]["id"], field.boundary.id
  end

  def test_retrieval_with_multiple_active_boundaries
    fixture = API_FIXTURES["field_with_multiple_active_boundaries"]

    stub_request(:get, /\/organizations\/#{ORGANIZATION_FIXTURE["id"]}\/fields\/#{fixture["id"]}/).
      with(query: {embed: "boundaries"}).
      to_return(status: 200, body: fixture.to_json)

    assert_raises MyJohnDeere::MyJohnDeereError, "At the moment I don't have a use case where this would happen" do
      field = MyJohnDeere::Field.retrieve(default_access_token, 
        fixture["id"], organization_id: ORGANIZATION_FIXTURE["id"],
        body: {embed: "boundaries"})
    end
  end

  def test_list()
    stub_request(:get, /organizations\/#{ORGANIZATION_FIXTURE["id"]}\/fields/).
      to_return(status: 200, body: FIXTURE_FOR_LIST.to_json)

    fields = MyJohnDeere::Field.list(default_access_token, 
      count: 1, organization_id: ORGANIZATION_FIXTURE["id"])

    assert_equal 1, fields.data.length
    assert fields.has_more?
    assert_equal MyJohnDeere::Field, fields.data[0].class

    fields.next_page!

    assert_equal 1, fields.data.count
  end
end