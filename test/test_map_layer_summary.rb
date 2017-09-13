require File.expand_path('../test_helper', __FILE__)

class TestMapLayerSummary < Minitest::Test
  FIXTURE = API_FIXTURES.fetch("map_layer_summary")
  FIXTURE_FOR_LIST = API_FIXTURES.fetch("map_layer_summaries")

  def test_retrieve()
    stub_request(:get, /\/mapLayerSummaries\/#{FIXTURE["id"]}/).
      to_return(status: 200, body: FIXTURE.to_json)

    mls = MyJohnDeere::MapLayerSummary.retrieve(default_access_token, FIXTURE["id"])
    assert_equal "2516aa2c-2c0d-4dae-ba63-5c44ff172a01", mls.id
    assert_equal "1234", mls.organization_id
    assert_equal "some title", mls.title
    assert_equal "description of the map layers", mls.text
    assert_equal [{"name"=>"The Name", "value"=>"The Value"}], mls.metadata
    assert_equal Time, mls.date_created.class
    assert_equal Time, mls.last_modified_date.class
  end

  def test_list
    organization_id = "1234"
    field_id = "2516aa2c-2c0d-4dae-ba63-5c64fd172d01"
    stub_request(:get, /organizations\/#{organization_id}\/fields\/#{field_id}\/mapLayerSummaries/).
      to_return(status: 200, body: FIXTURE_FOR_LIST.to_json)

    mlss = MyJohnDeere::MapLayerSummary.list(default_access_token, count: 1, 
      organization_id: organization_id, field_id: field_id)

    assert_equal 1, mlss.data.length
    assert_equal MyJohnDeere::MapLayerSummary, mlss.data[0].class
  end
end