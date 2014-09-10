class TestApp < Sinatra::Application
  configure do
    enable :sessions
    set :show_exceptions, false
    set :session_secret, ENV["SESSION_SECRET"]
  end

  use OmniAuth::Builder do
    provider :heroku, ENV["HEROKU_OAUTH_ID"], ENV["HEROKU_OAUTH_SECRET"]
  end

  get "/" do
    "ohhai"
  end

  get "/auth/heroku/callback" do
    "logged in"
  end
end