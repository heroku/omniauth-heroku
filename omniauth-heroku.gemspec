Gem::Specification.new do |gem|
  gem.authors       = ["Pedro Belo"]
  gem.email         = ["pedro@heroku.com"]
  gem.description   = %q{OmniAuth strategy for Heroku.}
  gem.summary       = %q{OmniAuth strategy for Heroku.}
  gem.homepage      = "https://github.com/heroku/omniauth-heroku"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.name          = "omniauth-heroku"
  gem.require_paths = ["lib"]
  gem.version       = "0.2.0.pre"

  gem.add_dependency 'omniauth', '~> 1.2'
  gem.add_dependency 'omniauth-oauth2', '~> 1.2'
end
