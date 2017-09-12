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

  def test_list_with_etag
    stub_request(:get, /organizations/).
      with(headers: {MyJohnDeere::ETAG_HEADER_KEY => ""}).
      to_return(status: 200, body: LIST_FIXTURE.to_json(), headers: {MyJohnDeere::ETAG_HEADER_KEY=>"something"})

    organizations = MyJohnDeere::Organization.list(default_access_token, count: 1, etag: "")

    assert_equal "something", organizations.etag
  end

  def test_list_with_body
    stub_request(:get, /organizations;start=0;count=1/).
      with(query: {embed: "boundaries"}).
      to_return(status: 200, body: LIST_FIXTURE.to_json())
    organizations = MyJohnDeere::Organization.list(default_access_token, count: 1, etag: "", body: {embed: "boundaries"})
    assert_equal({:embed=>"boundaries"}, organizations.options[:body])
  end
end