require File.expand_path('../test_helper', __FILE__)

class TestAccessToken < Minitest::Test
  def test_get_request_token
    expected_secret = "v8gWA1cxT1Gfx1nkxi01R8xy6uHbMLw/9cMzYTl9bqqTPJWQkRpZr5WmMQA0S4clamix2tGMD5rlfvXis7DxGKcxA6ZIMGXLK1mMOegnM78="
    expected_token = "12ac3ff0-a13e-4c61-83f4-5cf9bd532341"

    stub_request(:get, "#{MyJohnDeere.configuration.endpoint}/oauth/request_token").
      to_return(status: 200, body: "oauth_token=#{expected_token}&oauth_token_secret=#{expected_secret}&oauth_callback_confirmed=true")
    rt = MyJohnDeere::AccessToken.get_request_token()

    assert_equal expected_token, rt.token
    assert_equal expected_secret, rt.secret
  end

  def test_initialize_without_exact_options
    assert_raises ArgumentError do
      MyJohnDeere::AccessToken.new()
    end
  end

  def test_initialize_access_token_with_request_token
    expected_secret = "1Of2eWDVM2x90j1kjxVgxlz091kjmnndsa0912FYwz7ZxlVgPcPmFGb1RtBWLXGVw3k"
    expected_token = "2f05ab26-1879-4bfe-9129-b9b0144d1610"
    
    stub_request(:post, "#{MyJohnDeere.configuration.endpoint}/oauth/access_token").
      to_return(status: 200, body: "oauth_token=#{expected_token}&oauth_token_secret=#{expected_secret}", headers: {})
    at = MyJohnDeere::AccessToken.new(
      request_token_token: "12ac3ff0-a13e-4c61-83f4-5cf9bd532341",
      request_token_secret: "v8gWA1cxT1Gfx1nkxi01R8xy6uHbMLw/9cMzYTl9bqqTPJWQkRpZr5WmMQA0S4clamix2tGMD5rlfvXis7DxGKcxA6ZIMGXLK1mMOegnM78=",
      verifier_code: "blah"
    )

    assert_equal expected_token, at.token
    assert_equal expected_secret, at.secret
  end

  def test_initialize_access_token_with_access_token_options
    expected_secret = "1Of2eWDVM2x90j1kjxVgxlz091kjmnndsa0912FYwz7ZxlVgPcPmFGb1RtBWLXGVw3k"
    expected_token = "2f05ab26-1879-4bfe-9129-b9b0144d1610"
    
    at = MyJohnDeere::AccessToken.new(
      oauth_access_token_token: expected_token,
      oauth_access_token_secret: expected_secret,
    )
    assert_equal expected_token, at.token
    assert_equal expected_secret, at.secret
  end

  def test_send_request_with_bad_responses
    at = default_access_token()
    code_and_error = [[503, MyJohnDeere::ServerBusyError],
    [400, MyJohnDeere::InvalidRequestError],
    [404, MyJohnDeere::InvalidRequestError],
    [401, MyJohnDeere::AuthenticationError],
    [403, MyJohnDeere::PermissionError],
    [429, MyJohnDeere::RateLimitError],
    [500, MyJohnDeere::InternalServerError]]

    code_and_error.each do |c_e|
      stub_request(:get, //).
        to_return(status: c_e[0], body: "Stuff")

      assert_raises c_e[1], "Expected #{c_e[0]} to raise #{c_e[1]}" do
        at.execute_request(:get, "/")
      end
    end
  end

  def test_send_get_request
    at = default_access_token()
    expected_json = API_FIXTURES.fetch("api_catalog")
    stub_request(:get, "https://sandboxapi.deere.com/platform/").
      to_return(status: 200, body: JSON.generate(expected_json), headers: {})

    response = at.execute_request(:get, "/")
    assert_equal 200, response.http_status
    assert_equal expected_json.to_json, response.data.to_json
  end
end