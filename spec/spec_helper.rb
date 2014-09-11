ENV["SESSION_SECRET"] = "abcdefghjij"
ENV["HEROKU_OAUTH_ID"] = "12345"
ENV["HEROKU_OAUTH_SECRET"] = "klmnopqrstu"

require "rubygems"
require "bundler"
Bundler.setup(:default, :test)
require "omniauth/strategies/heroku"

require "cgi"
require "rspec"
require "rack/test"
require "sinatra"
require "webmock/rspec"

Dir["./spec/support/*.rb"].each { |f| require f }

WebMock.disable_net_connect!

OmniAuth.config.logger = Logger.new(StringIO.new)

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.expect_with :minitest

  def app
    @app || make_app
  end

  def make_app(omniauth_heroku_options={})
    Sinatra.new do
      configure do
        enable :sessions
        set :show_exceptions, false
        set :session_secret, ENV["SESSION_SECRET"]
      end

      use OmniAuth::Builder do
        provider :heroku, ENV["HEROKU_OAUTH_ID"], ENV["HEROKU_OAUTH_SECRET"],
          omniauth_heroku_options
      end

      get "/auth/heroku/callback" do
        MultiJson.encode(env['omniauth.auth'])
      end
    end
  end
end
