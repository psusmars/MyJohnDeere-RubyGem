require File.expand_path('../test_helper', __FILE__)

class TestMapLayer < Minitest::Test
  FIXTURE = API_FIXTURES.fetch("map_layer")
  FIXTURE_FOR_LIST = API_FIXTURES.fetch("map_layers")
  ORGANIZATION_ID = "1234"
  MAP_LAYER_ID = "83ks9gh3-29fj-9302-837j-92jlsk92jd095kd"
  MLS_ID = "2516aa2c-1c0d-4dae-ba63-5c44ff172a01"
  FIELD_ID = "2516aa2c-2c0d-4dae-ba63-5c44ff172a01"

  def test_retrieve()
    stub_request(:get, /\/mapLayers\/#{FIXTURE["id"]}/).
      to_return(status: 200, body: FIXTURE.to_json)

    ml = MyJohnDeere::MapLayer.retrieve(default_access_token, FIXTURE["id"])
    assert_equal MAP_LAYER_ID, ml.id
    assert_equal ORGANIZATION_ID, ml.organization_id
    assert_equal "The title on the map layer", ml.title
    assert_equal 4, ml.extent.length
    assert_equal "seeds1ha-1", ml.legends["unitId"]
    assert_equal 1, ml.legends["ranges"].length
    assert_equal MyJohnDeere::MapLegendItem, ml.legends["ranges"][0].class, "Should be a map legend item"
    assert_equal({:label=>"Some Label", :minimum=>87300, :maximum=>87300, :hexColor=>"#0BA74A", :percent=>0.13},
      ml.legends["ranges"][0].to_hash)
  end

  def test_to_s
    stub_request(:get, /\/mapLayers\/#{FIXTURE["id"]}/).
      to_return(status: 200, body: FIXTURE.to_json)

    ml = MyJohnDeere::MapLayer.retrieve(default_access_token, FIXTURE["id"])

    assert_equal "MyJohnDeere::MapLayer: {:id=>\"83ks9gh3-29fj-9302-837j-92jlsk92jd095kd\", :title=>\"The title on the map layer\", :extent=>{\"minimumLatitude\"=>41.76073, \"maximumLatitude\"=>41.771366, \"minimumLongitude\"=>-93.488106, \"maximumLongitude\"=>-93.4837}, :legends=>{\"unitId\"=>\"seeds1ha-1\", \"ranges\"=>[#<MyJohnDeere::MapLegendItem:0xXXXXXX @label=\"Some Label\", @minimum=87300, @maximum=87300, @hex_color=\"#0BA74A\", @percent=0.13>]}}", ml.to_s
  end

  def test_list
    stub_request(:get, /mapLayerSummaries\/#{MLS_ID}\/mapLayers/).
      to_return(status: 200, body: FIXTURE_FOR_LIST.to_json)

    map_layers = MyJohnDeere::MapLayer.list(default_access_token, count: 1, 
      map_layer_summary_id: MLS_ID)

    assert_equal 1, map_layers.data.length
    assert_equal MyJohnDeere::MapLayer, map_layers.data[0].class
  end

  def test_create
    expected_body = "{\"links\":[{\"rel\":\"owningOrganization\",\"uri\":\"https://sandboxapi.deere.com/platform/organizations/1234\"}],\"title\":\"blah\",\"extent\":{\"minimumLatitude\":0,\"maximumLatitude\":1,\"minimumLongitude\":0,\"maximumLongitude\":1},\"legends\":{\"unitId\":\"foo\",\"ranges\":[{\"label\":\"bar\",\"minimum\":1,\"maximum\":2,\"hexColor\":\"#0BA74A\",\"percent\":15.0}]}}"
    stub_request(:post, /mapLayerSummaries\/#{MLS_ID}\/mapLayers/).
      with(body: expected_body,
       headers: {'Accept'=>'application/vnd.deere.axiom.v3+json', 'Content-Length'=>expected_body.length, 'Content-Type'=>'application/vnd.deere.axiom.v3+json'}).
      to_return(status: 201, headers: {"Location"=>"https://sandboxapi.deere.com/platform/mapLayers/#{MAP_LAYER_ID}"})
    response = MyJohnDeere::MapLayer.create(default_access_token, 
      MLS_ID,
      ORGANIZATION_ID,
      minimum_latitude: 0, minimum_longitude: 0, maximum_latitude: 1, maximum_longitude: 1,
      title: "blah",
      map_layer_id: "foo", map_legend_items: [MyJohnDeere::MapLegendItem.new("bar", 1, 2, "#0BA74A", 15.0)]
    )
    assert_equal MAP_LAYER_ID, response.id
    assert_equal ORGANIZATION_ID, response.organization_id
  end
end