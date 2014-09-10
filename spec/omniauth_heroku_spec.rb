require "spec_helper"

describe OmniAuth::Strategies::Heroku do
  it "redirects to start the OAuth flow" do
    get "/auth/heroku"
    assert_equal 302, last_response.status
    redirect = URI.parse(last_response.headers["Location"])
    redirect_params = CGI::parse(redirect.query)
    assert_equal "https", redirect.scheme
    assert_equal "id.heroku.com", redirect.host
    assert_equal [ENV["HEROKU_OAUTH_ID"]], redirect_params["client_id"]
    assert_equal ["code"], redirect_params["response_type"]
    assert_equal ["http://example.org/auth/heroku/callback"],
      redirect_params["redirect_uri"]
  end
end