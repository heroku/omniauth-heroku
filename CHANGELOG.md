# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.1] 2021-07-06

### Changed
- Lock to `omniauth-oauth2 ~> 1.6.0` to fix regression in dynamic `scope:` option.
  The following is broken in `omniauth-oauth2 >= 1.7.0` which will pass along the Rack `env` as the block parameter.

  ```ruby
  use OmniAuth::Builder do
    provider :heroku, ENV.fetch("HEROKU_OAUTH_ID"), ENV.fetch("HEROKU_OAUTH_SECRET"),
      scope: ->(request) { request.params["scope"] || "identity" }
  end
  ```

  This results in an error because `#params` is not a method of `Hash`.
