require File.expand_path('../test_helper', __FILE__)

class TestListObject < Minitest::Test
  def test_each_loop
    data = Array.new(3, API_FIXTURES["organization"])
    list = MyJohnDeere::ListObject.new(MyJohnDeere::Organization, 
      default_access_token, 
      {"values" => data},
      200,
      {})

    list.each_with_index do |x, i|
      assert_equal data[i]["id"], x.id
    end

    assert_equal data.length, list.total
  end

  def test_has_more
    expected_total = 3
    list = MyJohnDeere::ListObject.new(MyJohnDeere::Organization,
      default_access_token, {
        "total" => expected_total,
        "values" => Array.new(1, API_FIXTURES["organization"])
      }, {}, options: {start: 0})
    assert list.has_more?

    list.start = expected_total
    assert !list.has_more?

    list = MyJohnDeere::ListObject.new(MyJohnDeere::Organization,
      default_access_token, {"values" =>[]}, {}, options: {start: 0})
    assert !list.has_more?, "The data is equal to the total"
  end

  def test_not_modified_with_etag
    etag_val = "something"
    new_etag = "something2"
    # Validate that the etag header is getting propagated to the next request
    stub_request(:get, /organizations/).
      with(headers: {MyJohnDeere::ETAG_HEADER_KEY=>etag_val}).
      to_return(status: 304, body: '', headers: {MyJohnDeere::ETAG_HEADER_KEY=>new_etag})
    organizations = MyJohnDeere::Organization.list(default_access_token, etag: etag_val)

    assert_equal 0, organizations.data.count
    assert organizations.not_modified?
  end

  def test_get_next_page_with_etag
    # etag behavior gets the entire list.
    test_json = API_FIXTURES["organizations"]
    existing_data = Array.new(test_json["total"]-1, test_json["values"][0])
    list = MyJohnDeere::ListObject.new(MyJohnDeere::Organization, default_access_token, 
      {"values" => existing_data}, 200, {}, options: {
        start: 0, count: existing_data.length, etag: ""})
    assert list.using_etag?
    assert !list.has_more?
    assert_equal list.data.length, list.data.length
    assert_equal 0, list.start

    # Validate that the etag header is getting propagated to the next request
    list.next_page!()

    assert_equal list.data.length, list.data.length, "shouldn't have changed"
    assert_equal 0, list.start, "shouldn't have changed"
  end

  def test_get_next_page
    test_json = API_FIXTURES["organizations"]
    existing_data = (1..(test_json["total"]-1)).to_a
    list = MyJohnDeere::ListObject.new(MyJohnDeere::Organization, default_access_token, 
      test_json, 200, {}, options: {start: 0,
      count: existing_data.length})
    assert list.has_more?
    assert !list.using_etag?

    stub_request(:get, /organizations;start=#{existing_data.count};count=#{existing_data.count}/).
      with(headers: {'Accept'=>'application/vnd.deere.axiom.v3+json'}).
      to_return(status: 200, body: test_json.to_json())

    list.next_page!()

    assert_equal 1, list.data.length
    assert_equal existing_data.length, list.start
    assert_equal test_json["values"].first["id"], list.data.first.id
    assert !list.has_more?()
  end
end