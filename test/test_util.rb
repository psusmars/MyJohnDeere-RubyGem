require File.expand_path('../test_helper', __FILE__)

class TestUtil < Minitest::Test
  def test_build_url_get_method_behavior
    expected_path = "/organizations?something=1"
    expected_headers = {"accept"=>"application/vnd.deere.axiom.v3+json", "blah"=>"1"}
    path, headers, body = MyJohnDeere::Util.build_path_headers_and_body(:get, "organizations", 
      headers: {"blah" => "1"}, body: {"something" => 1},
      etag: nil)

    assert_equal expected_path, path,
      "Should have put the body in the path and a leading slash"
    assert_equal expected_headers, headers, 
      "Should have put our header in and the default request header"

    path, headers, body = MyJohnDeere::Util.build_path_headers_and_body(:get, "/organizations", 
      headers: {"blah" => "1"}, body: {"something" => 1},
      etag: nil)

    expected_headers["X-Deere-Signature"] = ""
    path, headers, body = MyJohnDeere::Util.build_path_headers_and_body(:get, "/organizations", 
      headers: {"blah" => "1"}, body: {"something" => 1},
      etag: "")    
    assert_equal expected_path, path
    assert_equal expected_headers, headers, 
      "We used a blank string for the etag indicating we want the behavior"

    expected_path = "/organizations;start=10;count=10?something=1"
    path, headers, body = MyJohnDeere::Util.build_path_headers_and_body(:get, "/organizations", 
      headers: {"blah" => "1"}, body: {"something" => 1, count: 10, start: 10},
      etag: "")
    assert_equal expected_path, path, "Should put the start and count in the path"

    path, headers, body = MyJohnDeere::Util.build_path_headers_and_body(:get, "/organizations;start=10", 
      headers: {"blah" => "1"}, body: {"something" => 1, start: 10, count: 10},
      etag: "")    
    assert_equal expected_path, path, "Shouldn't add extra start since we have it already"
  end

  def test_etag_with_blank_body
    path, headers, body = MyJohnDeere::Util.build_path_headers_and_body(:get, "test", etag: "", body: "")
    assert_equal({"accept"=>"application/vnd.deere.axiom.v3+json", "X-Deere-Signature"=>""}, headers)
  end

  def test_url_cleanup
    expected_path = "/organizations"
    path, headers, body = MyJohnDeere::Util.build_path_headers_and_body(:get, expected_path)
    assert_equal expected_path, path, "Shouldn't care about the leading slash"
    assert_equal({"accept"=>"application/vnd.deere.axiom.v3+json"}, headers,
      "Headers should just be the default request headers")

    path, headers, body = MyJohnDeere::Util.build_path_headers_and_body(:get, "platform/organizations")
    assert_equal expected_path, path, "Shouldn't care about the leading platform"

    path, headers, body = MyJohnDeere::Util.build_path_headers_and_body(:get, "#{MyJohnDeere.configuration.endpoint}/organizations")
    assert_equal expected_path, path, "Should remove the extra uri at the front since we probably pulled from a link object in the json"
  end

  def test_post_setup
    expected_headers = {"accept"=>"application/vnd.deere.axiom.v3+json", "Content-Type"=>"application/vnd.deere.axiom.v3+json", "blah"=>"1"}
    input_header = {"blah" => "1"}
    path, headers, body = MyJohnDeere::Util.build_path_headers_and_body(:post, "/organizations", 
      headers: input_header)
    assert_equal "/organizations", path, "Shouldn't do anything to the path"
    assert_equal expected_headers, headers, "Shouldn't have anything about content_length"
    assert_equal "", body, "Should be an empty body"

    expected_body = {"something" => 1}
    expected_headers["Content-Length"] = expected_body.to_json.length.to_s
    path, headers, body = MyJohnDeere::Util.build_path_headers_and_body(:post, "/organizations", 
      headers: input_header, body: expected_body)
    assert_equal "/organizations", path, "Shouldn't do anything to the path"
    assert_equal expected_headers, headers, "should now include the content_length"
    assert JSON.parse(body), "The body should be JSON parsable"

    expected_body = {"something" => 1}.to_json
    expected_headers["Content-Length"] = expected_body.length.to_s
    path, headers, body = MyJohnDeere::Util.build_path_headers_and_body(:post, "/organizations", 
      headers: input_header, body: expected_body)
    assert_equal "/organizations", path, "Shouldn't do anything to the path"
    assert_equal expected_headers, headers, "Shouldn't have anything about content_length"
    assert JSON.parse(body), "The body should be JSON parsable and should be ready to go since we did the json conversion"
  end
end