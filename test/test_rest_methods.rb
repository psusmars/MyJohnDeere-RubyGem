require File.expand_path('../test_helper', __FILE__)

class TestRestMethods < Minitest::Test
  LIST_FIXTURE = API_FIXTURES["organizations"]
  def test_argument_validation_on_list()
    assert_raises ArgumentError do
      MyJohnDeere::Organization.list(nil, count: 1)
    end
  end

  def test_argument_validation_on_retrieve
    assert_raises ArgumentError do
      MyJohnDeere::Organization.retrieve(nil, 1234)
    end
  end

  def test_delete
    stub_request(:delete, /mapLayerSummaries/).
      to_return(status: 204)

    assert MyJohnDeere::MapLayerSummary.delete(default_access_token, "foobar")

    assert_raises MyJohnDeere::UnsupportedRequestError do
      MyJohnDeere::Organization.delete(default_access_token, "foobar")
    end
  end

  def test_list_with_etag
    stub_request(:get, /organizations/).
      with(headers: {MyJohnDeere::ETAG_HEADER_KEY => ""}).
      to_return(status: 200, body: LIST_FIXTURE.to_json(), headers: {MyJohnDeere::ETAG_HEADER_KEY=>"something"})

    organizations = MyJohnDeere::Organization.list(default_access_token, count: 1, etag: "")

    assert_equal "something", organizations.etag
  end

  def test_build_resource_base_path
    resource_path = "blah"
    assert_equal "blah", MyJohnDeere::Organization.build_resource_base_path!("blah", {})
    resource_path = "blah%{x_id}"
    options = {x: 5, x_id: 1}
    assert_equal "blah1", MyJohnDeere::Organization.build_resource_base_path!(resource_path, options)
    assert_equal({x: 5}, options)

    assert_raises ArgumentError do
      MyJohnDeere::Organization.build_resource_base_path!(resource_path, {})
    end
  end

  def test_list_with_body
    stub_request(:get, /organizations;start=0;count=1/).
      with(query: {embed: "boundaries"}).
      to_return(status: 200, body: LIST_FIXTURE.to_json())
    organizations = MyJohnDeere::Organization.list(default_access_token, count: 1, etag: "", body: {embed: "boundaries"})
    assert_equal({:embed=>"boundaries"}, organizations.options[:body])
  end
end