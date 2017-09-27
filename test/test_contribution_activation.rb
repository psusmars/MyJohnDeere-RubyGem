require File.expand_path('../test_helper', __FILE__)

class TestContributionActivation < Minitest::Test
  FIXTURE = API_FIXTURES.fetch("contribution_activation")
  ORGANIZATION_ID = "1234"
  CONTRIBUTION_PRODUCT_ID = "9bd2876a-c423-4a2a-8c25-bff66dde76fe"
  CONTRIBUTION_ACTIVATION_ID = "90d20db5-6bdd-466f-a0ec-17c6271a0a2a"

  def test_retrieve()
    stub_request(:get, /\/contributionActivations\/#{CONTRIBUTION_ACTIVATION_ID}/).
      to_return(status: 200, body: FIXTURE.to_json)

    ca = MyJohnDeere::ContributionActivation.retrieve(default_access_token, 
      CONTRIBUTION_ACTIVATION_ID)
    assert_equal CONTRIBUTION_ACTIVATION_ID, ca.id
    assert_equal CONTRIBUTION_PRODUCT_ID, ca.contribution_product_id
    assert_equal "ACTIVATED", ca.activation_status
  end

  def test_create
    expected_body = {"@type"=>"ContributionActivation",
 "activationStatus"=>"ACTIVATED",
 "links"=>
  [{"@type"=>"Link",
    "rel"=>"ContributionProduct",
    "uri"=>
     "https://sandboxapi.deere.com/platform/contributionProducts/#{CONTRIBUTION_PRODUCT_ID}"}]}.to_json()
    stub_request(:post, /contributionActivations/).
      with(body: expected_body,
      headers: {'Accept'=>'application/vnd.deere.axiom.v3+json', 'Content-Length'=>expected_body.length, 'Content-Type'=>'application/vnd.deere.axiom.v3+json'}).
      to_return(status: 201, headers: {"Location"=>"https://sandboxapi.deere.com/platform/contributionActivations/#{CONTRIBUTION_ACTIVATION_ID}"})
    response = MyJohnDeere::ContributionActivation.create(default_access_token, 
      ORGANIZATION_ID,
      CONTRIBUTION_PRODUCT_ID,
      activated: true
    )
    assert_equal CONTRIBUTION_ACTIVATION_ID, response.id
  end
end