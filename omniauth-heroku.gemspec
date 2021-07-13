require File.expand_path("lib/omniauth/heroku/version", __dir__)

Gem::Specification.new do |spec|
  spec.name = "omniauth-heroku"
  spec.version = OmniAuth::Heroku::VERSION
  spec.authors = ["Pedro Belo"]
  spec.email = ["pedro@heroku.com"]

  spec.summary = "OmniAuth strategy for Heroku."
  spec.description = "OmniAuth strategy for Heroku, for apps already using OmniAuth that authenticate against more than one service (eg: Heroku and GitHub), or apps that have specific needs on session management."
  spec.homepage = "https://github.com/heroku/omniauth-heroku"
  spec.license = "MIT"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "changelog_uri" => "#{spec.homepage}/blob/master/CHANGELOG.md"
  }

  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = []
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("omniauth", [">= 1.9", "< 3"])
  spec.add_runtime_dependency("omniauth-oauth2", "~> 1.7")

  spec.add_development_dependency("multi_json", "~> 1.12")
  spec.add_development_dependency("rake", "~> 13.0")
  spec.add_development_dependency("rspec", "~> 3.4")
  spec.add_development_dependency("webmock", "~> 3.13")
end
