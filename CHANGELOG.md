# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.1] 2021-07-06

### Changed
- Lock to `omniauth-oauth2 ~> 1.6.0` to fix regression in dynamic `:scope` option.
  With `omniauth-oauth2 >= 1.7.0`, the block is passed the Rack `env` as the parameter.
  This breaks our expectation the will receive a `Rack::Request` instance as the argument to dynamically determine the `:scope` option.
  i.e., this broken:

  ```ruby
  use OmniAuth::Builder do
    provider :heroku, ENV.fetch("HEROKU_OAUTH_ID"), ENV.fetch("HEROKU_OAUTH_SECRET"),
      scope: ->(request) { request.params["scope"] || "identity" }
  end
  ```

  See [PR #22](https://github.com/heroku/omniauth-heroku/pull/22) for more context, workaround, etc...
