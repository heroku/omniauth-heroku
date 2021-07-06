Gem::Specification.new do |gem|
  gem.name = "omniauth-heroku"
  gem.authors = ["Pedro Belo"]
  gem.email = ["pedro@heroku.com"]
  gem.description = "OmniAuth strategy for Heroku."
  gem.summary = "OmniAuth strategy for Heroku."
  gem.homepage = "https://github.com/heroku/omniauth-heroku"
  gem.license = "MIT"

  gem.files = Dir["README.md", "LICENSE", "lib/**/*"]
  gem.require_path = "lib"
  gem.version = "0.4.1"

  gem.add_runtime_dependency("omniauth", "~> 1.9.0")
  # omniauth-oauth2 made a change in 1.7.0 which breaks our expectation
  # you can use a block accepting a `Rack::Request` object as the argument
  # to dynmically determine the `:scope` option. i.e., this broken:
  #
  # use OmniAuth::Builder do
  #   provider :heroku, ENV.fetch("HEROKU_OAUTH_ID"), ENV.fetch("HEROKU_OAUTH_SECRET"),
  #     scope: ->(request) { request.params["scope"] || "identity" }
  # end
  #
  # We'll lock down the allowed version, cut a point release, and then
  # release the lock in a new minor release.
  gem.add_runtime_dependency("omniauth-oauth2", "~> 1.6.0")

  gem.add_development_dependency("minitest", "~> 5.8")
  gem.add_development_dependency("multi_json", "~> 1.12")
  gem.add_development_dependency("rack-test", "~> 0.6")
  gem.add_development_dependency("rake", "~> 11.2")
  gem.add_development_dependency("rspec", "~> 3.4")
  gem.add_development_dependency("sinatra", "~> 1.4")
  gem.add_development_dependency("webmock", "~> 2.1")
end
