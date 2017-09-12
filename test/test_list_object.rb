require File.expand_path('../test_helper', __FILE__)

class TestListObject < Minitest::Test
  def test_each_loop
    data = ["x","y","z"]
    list = MyJohnDeere::ListObject.new(MyJohnDeere::Organization, 
      default_access_token, 
      data)

    list.each_with_index do |x, i|
      assert_equal data[i], x
    end

    assert_equal data.length, list.total
  end

  def test_has_more
    expected_total = 3
    list = MyJohnDeere::ListObject.new(MyJohnDeere::Organization,
      default_access_token, [], total: expected_total, options: {start: 0})
    assert list.has_more?

    list.start = expected_total
    assert !list.has_more?

    list = MyJohnDeere::ListObject.new(MyJohnDeere::Organization,
      default_access_token, (1..3).to_a, total: expected_total, options: {start: 0})
    assert !list.has_more?, "The data is equal to the total"
  end

  def test_get_next_page_with_etag
    # etag behavior gets the entire list.
    test_json = API_FIXTURES["organizations"]
    existing_data = (1..(test_json["total"]-1)).to_a
    list = MyJohnDeere::ListObject.new(MyJohnDeere::Organization, default_access_token, 
      existing_data, total: test_json["total"], options: {
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
      existing_data, total: test_json["total"], options: {start: 0,
      count: existing_data.length})
    assert list.has_more?
    assert !list.using_etag?

    # Validate that the etag header is getting propagated to the next request
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