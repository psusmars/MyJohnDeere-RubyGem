require File.expand_path('../test_helper', __FILE__)

class TestFile < Minitest::Test
  FIXTURE = API_FIXTURES.fetch("file")
  FIXTURE_FOR_LIST = API_FIXTURES.fetch("files")
  FILE_ID = "577499742"
  ORGANIZATION_ID = "1234"

  def test_retrieve()
    stub_request(:get, /\/files\/#{FILE_ID}/).
      to_return(status: 200, body: FIXTURE.to_json)

    file = MyJohnDeere::File.retrieve(default_access_token, FILE_ID)
    assert_equal "577499742", file.id
    assert_equal "back40.zip", file.name
    assert_equal "SETUP", file.type
    assert_equal Time.parse("2015-02-03T10:42:24.282Z"), file.created_time
    assert_equal Time.parse("2015-02-03T10:42:24.282Z"), file.modified_time
    assert_equal "72946", file.native_size
    assert_equal "JohnDoe", file.source
    assert_equal false, file.transfer_pending
    assert_equal "owned", file.visible_via_share
    assert_equal false, file.shared
    assert_equal "UPLOAD_PENDING", file.status
    assert_equal false, file.archived
    assert_equal true, file.new
    assert_equal ORGANIZATION_ID, file.organization_id
  end

  def test_list
    stub_request(:get, /organizations\/#{ORGANIZATION_ID}\/files/).
      to_return(status: 200, body: FIXTURE_FOR_LIST.to_json)

    files = MyJohnDeere::File.list(default_access_token,
      organization_id: ORGANIZATION_ID)

    assert_equal 1, files.data.length
    assert_equal MyJohnDeere::File, files.data[0].class
  end

  def test_created_argument_checking
    assert_raises ArgumentError do
      MyJohnDeere::File.create(default_access_token, 
        ORGANIZATION_ID,
        name: nil
      )
    end
  end

  def test_upload_url
    assert_equal "https://sandboxapi.deere.com/platform/files/1234", MyJohnDeere::File.new("id" => "1234").upload_url
  end

  def test_create
    expected_name = "blah"
    expected_body = {
      name: expected_name
    }.to_json
    stub_request(:post, /organizations\/#{ORGANIZATION_ID}\/files/).
      with(body: expected_body,
       headers: {'Accept'=>'application/vnd.deere.axiom.v3+json', 'Content-Length'=>expected_body.length, 'Content-Type'=>'application/vnd.deere.axiom.v3+json'}).
      to_return(status: 201, headers: {"Location"=>"https://sandboxapi.deere.com/platform/files/#{FILE_ID}"})
    response = MyJohnDeere::File.create(default_access_token, 
      ORGANIZATION_ID,
      name: expected_name
    )
    assert_equal FILE_ID, response.id
    assert_equal ORGANIZATION_ID, response.organization_id
    assert_equal "blah", response.name
  end
end