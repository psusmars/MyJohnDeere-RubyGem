require File.expand_path('../test_helper', __FILE__)

class TestField < Minitest::Test
  FIXTURE = API_FIXTURES.fetch(:field)

  def test_retrieve()
    expected_organization_id = API_FIXTURES[:organization][:id]
    expected_field_id = FIXTURE[:id]
    stub_request(:get, /\/organizations\/#{expected_organization_id}\/fields\/#{expected_field_id}/).
      to_return(status: 200, body: FIXTURE.to_json)

    field = MyJohnDeere::Field.retrieve(default_access_token, 
      expected_organization_id, expected_field_id)

    assert_equal expected_field_id, field.id
    assert_equal expected_organization_id, field.organization_id
    assert_equal "Nautilus", field.name
    assert_equal FIXTURE[:links].length, field.links.length
  end
end