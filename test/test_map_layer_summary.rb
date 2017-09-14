require File.expand_path('../test_helper', __FILE__)

class TestMapLayerSummary < Minitest::Test
  FIXTURE = API_FIXTURES.fetch("map_layer_summary")
  FIXTURE_FOR_LIST = API_FIXTURES.fetch("map_layer_summaries")
  ORGANIZATION_ID = "1234"
  MLS_ID = "2516aa2c-1c0d-4dae-ba63-5c44ff172a01"
  FIELD_ID = "2516aa2c-2c0d-4dae-ba63-5c44ff172a01"

  def test_retrieve()
    stub_request(:get, /\/mapLayerSummaries\/#{FIXTURE["id"]}/).
      to_return(status: 200, body: FIXTURE.to_json)

    mls = MyJohnDeere::MapLayerSummary.retrieve(default_access_token, FIXTURE["id"])
    assert_equal MLS_ID, mls.id
    assert_equal ORGANIZATION_ID, mls.organization_id
    assert_equal "some title", mls.title
    assert_equal "description of the map layers", mls.text
    assert_equal [{"name"=>"The Name", "value"=>"The Value"}], mls.metadata
    assert_equal Time, mls.date_created.class
    assert_equal Time, mls.last_modified_date.class
  end

  def test_list
    stub_request(:get, /organizations\/#{ORGANIZATION_ID}\/fields\/#{FIELD_ID}\/mapLayerSummaries/).
      to_return(status: 200, body: FIXTURE_FOR_LIST.to_json)

    mlss = MyJohnDeere::MapLayerSummary.list(default_access_token, count: 1, 
      organization_id: ORGANIZATION_ID, field_id: FIELD_ID)

    assert_equal 1, mlss.data.length
    assert_equal MyJohnDeere::MapLayerSummary, mlss.data[0].class
  end

  def test_create
    expected_body = "{\"title\":\"Test number 2\",\"text\":\"Hello from farm lens again\",\"links\":[{\"rel\":\"owningOrganization\",\"uri\":\"https://sandboxapi.deere.com/platform/organizations/1234\"},{\"rel\":\"contributionDefinition\",\"uri\":\"https://sandboxapi.deere.com/platform/foobar\"}],\"metadata\":[{\"key\":\"key\",\"value\":\"val\"}],\"dateCreated\":\"2016-01-02T16:14:23.421Z\"}"
    stub_request(:post, /\/organizations\/#{ORGANIZATION_ID}\/fields\/#{FIELD_ID}\/mapLayerSummaries/).
      with(body: expected_body,
       headers: {'Accept'=>'application/vnd.deere.axiom.v3+json', 'Content-Length'=>expected_body.length, 'Content-Type'=>'application/vnd.deere.axiom.v3+json'}).
      to_return(status: 201, headers: {"Location"=>"https://sandboxapi.deere.com/platform/mapLayerSummaries/#{MLS_ID}"})
    response = MyJohnDeere::MapLayerSummary.create(default_access_token, 
      ORGANIZATION_ID,
      FIELD_ID,
      "Test number 2",
      "Hello from farm lens again",
      [MyJohnDeere::MetadataItem.new("key", "val")],
      Time.parse("2016-01-02T16:14:23.421Z")
    )
    assert_equal MLS_ID, response.id
    assert_equal ORGANIZATION_ID, response.organization_id
  end
end