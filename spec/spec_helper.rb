require "rubygems"
require "bundler"
Bundler.setup(:default, :test)
require "omniauth/strategies/heroku"

require "rspec"
require "rack/test"
require "sinatra"
Dir["./spec/support/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods

  def app
    TestApp
  end
end
