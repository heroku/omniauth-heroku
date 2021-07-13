# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Support `omniauth` versions `>= 1.9` but `< 3`.
  i.e., support version `2` which addresses some CVEs.
- Standardize syntax and style via [Standard.rb](https://github.com/testdouble/standard)

### Breaking

- Loosen `omniauth-oauth2` requirement to allow `>= 1.7.0`.
  With this change, blocks give to dynamically determine the `:scope` argument will be passed the Rack `env`, rather than an instance of the `Rack::Request`.
  You'll need to update your usages to create a new `Rack::Request` in the block:

  ```ruby
  use OmniAuth::Builder do
    provider :heroku, ENV.fetch("HEROKU_OAUTH_ID"), ENV.fetch("HEROKU_OAUTH_SECRET"),
      scope: ->(env) { Rack::Request.new(env).params["scope"] || "identity" }
  end
  ```
- Remove `AuthUrl` and `ApiUrl` constants from `OmniAuth::Strategies::Heroku`. 
  These were internal details, not meant to be part of the public API.
- Require Ruby >= 2.3.0.
  We already only supported this, but weren't explicit about it.

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
