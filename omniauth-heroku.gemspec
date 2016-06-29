Gem::Specification.new do |gem|
  gem.name          = "omniauth-heroku"
  gem.authors       = ["Pedro Belo"]
  gem.email         = ["pedro@heroku.com"]
  gem.description   = "OmniAuth strategy for Heroku."
  gem.summary       = "OmniAuth strategy for Heroku."
  gem.homepage      = "https://github.com/heroku/omniauth-heroku"
  gem.license       = "MIT"

  gem.files         = Dir["README.md", "LICENSE", "lib/**/*"]
  gem.require_path  = "lib"
  gem.version       = "0.3.0"

  gem.add_dependency "omniauth", "~> 1.2"
  gem.add_dependency "omniauth-oauth2", "~> 1.2"
end
