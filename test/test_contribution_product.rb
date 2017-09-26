require File.expand_path('../test_helper', __FILE__)

class TestContributionProduct < Minitest::Test
  FIXTURE = API_FIXTURES.fetch("contribution_product")
  CONTRIBUTION_PRODUCT_ID = "9bd2876a-c423-4a2a-8c25-bff66dde76fe"

  def test_retrieve()
    stub_request(:get, /\/contributionProducts\/#{CONTRIBUTION_PRODUCT_ID}/).
      to_return(status: 200, body: FIXTURE.to_json)

    cp = MyJohnDeere::ContributionProduct.retrieve(default_access_token, 
      CONTRIBUTION_PRODUCT_ID)
    assert_equal CONTRIBUTION_PRODUCT_ID, cp.id
    assert_equal "PRODUCT_NAME",
      cp.market_place_name
    assert_equal "PRODUCT_DESCRITPION",
      cp.market_place_description
    assert_equal "https://jd-us01-isg-prod-system.s3.amazonaws.com/b2b/branding/32902911-9f40-41f3-99eb-b0638ed185y7",
      cp.market_place_logo
    assert_equal "en-us",
      cp.default_locale
    assert_equal "APPROVED",
      cp.current_status
  end

  def test_retrieve()
    stub_request(:get, /\/contributionProducts/).
      to_return(status: 200, body: API_FIXTURES.fetch("contribution_products").to_json)

    cps = MyJohnDeere::ContributionProduct.list(default_access_token)
    assert_equal 1, cps.data.count
    assert_equal MyJohnDeere::ContributionProduct, cps.data[0].class
  end
end