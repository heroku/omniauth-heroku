require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Heroku < OmniAuth::Strategies::OAuth2
      BaseAuthUrl = ENV["HEROKU_AUTH_URL"] || "https://id.heroku.com"

      option :client_options, {
        :site => BaseAuthUrl,
        :authorize_url => "#{BaseAuthUrl}/oauth/authorize",
        :token_url => "#{BaseAuthUrl}/oauth/token"
      }
    end
  end
end
