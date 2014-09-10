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

  it "receives the callback" do
   stub_request(:post, "https://id.heroku.com/oauth/token").
     to_return(
      headers: { "Content-Type" => "application/json" },
      body: MultiJson.encode(
        access_token: "token",
        expires_in:   3600,
        user_id:      "ddc4beff-f08f-4856-99d2-ba5ac63c3eb9"))

    # start the callback, get the session state
    get "/auth/heroku"
    assert_equal 302, last_response.status
    state = last_response.headers["Location"].match(/state=([\w\d]+)/)[1]

    # trigger the callback setting the state as a param and in the session
    get "/auth/heroku/callback", { "state" => state },
      { "rack.session" => { "omniauth.state" => state }}
    assert_equal 200, last_response.status

    omniauth_env = MultiJson.decode(last_response.body)
    assert_equal "heroku", omniauth_env["provider"]
    assert_equal "ddc4beff-f08f-4856-99d2-ba5ac63c3eb9", omniauth_env["uid"]
  end
end
