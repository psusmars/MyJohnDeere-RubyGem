require File.expand_path('../test_helper', __FILE__)

class TestBoundary < Minitest::Test
  FIXTURE = API_FIXTURES.fetch("boundary")
  FIXTURE_FOR_LIST = API_FIXTURES.fetch("boundaries")
  ORGANIZATION_FIXTURE = API_FIXTURES.fetch("organization")

  def test_retrieve()
    expected_organization_id = ORGANIZATION_FIXTURE["id"]
    expected_boundary_id = FIXTURE["id"]
    stub_request(:get, /\/organizations\/#{expected_organization_id}\/boundaries\/#{expected_boundary_id}/).
      to_return(status: 200, body: FIXTURE.to_json)

    boundary = MyJohnDeere::Boundary.retrieve(default_access_token, 
      expected_boundary_id, organization_id: expected_organization_id)

    assert_equal expected_boundary_id, boundary.id
    assert_equal expected_organization_id, boundary.organization_id
    assert_nil boundary.field_id
    assert_equal true, boundary.active
    assert_equal "2/25/2015 6:01:19 PM", boundary.name
    assert_equal 1, boundary.multipolygons.length
  end

  def test_list
    organization_id = "1234"
    field_id = "6232611a-0303-0234-8g7d-e1e1e11871b8"
    stub_request(:get, /organizations\/#{organization_id}\/fields\/#{field_id}\/boundaries/).
      to_return(status: 200, body: FIXTURE_FOR_LIST.to_json)

    boundaries = MyJohnDeere::Boundary.list(default_access_token, count: 1, 
      organization_id: organization_id, field_id: field_id)

    assert_equal 1, boundaries.data.length
    assert_equal MyJohnDeere::Boundary, boundaries.data[0].class
  end
end