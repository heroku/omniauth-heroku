require "rubygems"
require "bundler"
Bundler.setup(:default, :test)
require "rspec"
require "omniauth/strategies/heroku"

RSpec.configure do |config|
end
