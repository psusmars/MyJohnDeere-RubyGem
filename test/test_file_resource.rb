require File.expand_path('../test_helper', __FILE__)

class TestFileResource < Minitest::Test
  FIXTURE = API_FIXTURES.fetch("file_resource")
  FIXTURE_FOR_LIST = API_FIXTURES.fetch("file_resources")
  FILE_RESOURCE_ID = FIXTURE["id"]
  ORGANIZATION_ID = "1234"
  MAP_LAYER_ID = "83ks9gh3-29fj-9302-837j-92jlsk92jd095kd"

  def test_retrieve()
    stub_request(:get, /\/fileResources\/#{FILE_RESOURCE_ID}/).
      to_return(status: 200, body: FIXTURE.to_json)

    file_resource = MyJohnDeere::FileResource.retrieve(default_access_token, FILE_RESOURCE_ID)
    assert_equal FILE_RESOURCE_ID, file_resource.id
    assert_equal ORGANIZATION_ID, file_resource.organization_id
    assert_equal "image/png", file_resource.mime_type
    assert_equal [{"name"=>"The Name", "value"=>"The Value"}], file_resource.metadata
    assert_equal Time, file_resource.timestamp.class
  end

  def test_list
    stub_request(:get, /mapLayers\/#{MAP_LAYER_ID}\/fileResources/).
      to_return(status: 200, body: FIXTURE_FOR_LIST.to_json)

    file_resources = MyJohnDeere::FileResource.list(default_access_token, count: 1, 
      map_layer_id: MAP_LAYER_ID)

    assert_equal 1, file_resources.data.length
    assert_equal MyJohnDeere::FileResource, file_resources.data[0].class
  end

  def test_created_argument_checking
    assert_raises ArgumentError do
      MyJohnDeere::FileResource.create(default_access_token, 
        nil,
        MAP_LAYER_ID,
        file_type: :zip,
        metadata: [MyJohnDeere::MetadataItem.new("key", "value")]
      )
    end

    assert_raises ArgumentError do
      MyJohnDeere::FileResource.create(default_access_token, 
        ORGANIZATION_ID,
        nil,
        file_type: :zip,
        metadata: [MyJohnDeere::MetadataItem.new("key", "value")]
      )
    end

    assert_raises ArgumentError do
      MyJohnDeere::FileResource.create(default_access_token, 
        ORGANIZATION_ID,
        MAP_LAYER_ID,
        file_type: nil,
        metadata: [MyJohnDeere::MetadataItem.new("key", "value")]
      )
    end
  end

  def test_create
    expected_body = "{\"links\":[{\"rel\":\"owningOrganization\",\"uri\":\"https://sandboxapi.deere.com/platform/organizations/1234\"}],\"mimeType\":\"application/zip\",\"metadata\":[{\"key\":\"key\",\"value\":\"value\"}]}"
    stub_request(:post, /mapLayers\/#{MAP_LAYER_ID}\/fileResources/).
      with(body: expected_body,
       headers: {'Accept'=>'application/vnd.deere.axiom.v3+json', 'Content-Length'=>expected_body.length, 'Content-Type'=>'application/vnd.deere.axiom.v3+json'}).
      to_return(status: 201, headers: {"Location"=>"https://sandboxapi.deere.com/platform/fileResources/#{FILE_RESOURCE_ID}"})
    response = MyJohnDeere::FileResource.create(default_access_token, 
      ORGANIZATION_ID,
      MAP_LAYER_ID,
      file_type: :zip,
      metadata: [MyJohnDeere::MetadataItem.new("key", "value")]
    )
    assert_equal FILE_RESOURCE_ID, response.id
    assert_equal ORGANIZATION_ID, response.organization_id
  end

  def test_upload_file
    stub_request(:put, /fileResources\/#{FILE_RESOURCE_ID}/).
      with(headers: {'Content-Length'=>'4407', 'Content-Type'=>'application/octet-stream'}).
      to_return(status: 204)
    
    success = MyJohnDeere::FileResource.upload_file(default_access_token, FILE_RESOURCE_ID,
      "#{PROJECT_ROOT}/spec/colored.png")

    assert success
  end
end