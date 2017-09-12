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
      default_access_token, [], total: expected_total, start: 0)
    assert list.has_more?

    list.start = expected_total
    assert !list.has_more?

    list = MyJohnDeere::ListObject.new(MyJohnDeere::Organization,
      default_access_token, (1..3).to_a, total: expected_total, start: 0)
    assert !list.has_more?, "The data is equal to the total"
  end

  def test_get_next_page
    test_json = API_FIXTURES[:organizations]
    existing_data = (1..(test_json[:total]-1)).to_a
    list = MyJohnDeere::ListObject.new(MyJohnDeere::Organization, default_access_token, 
      existing_data, total: test_json[:total], start: 0, count: existing_data.length)
    assert list.has_more?
    stub_request(:get, /organizations;start=#{existing_data.count};count=#{existing_data.count}/).
      to_return(status: 200, body: test_json.to_json())

    list.next_page()

    assert_equal 1, list.data.length
    assert_equal test_json[:values].first[:id], list.data.first.id
    assert !list.has_more?()
  end
end