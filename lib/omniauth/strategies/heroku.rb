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

      uid do
        raw_info['id']
      end

      info do
        {
          'name' => raw_info['name'],
          'email' => raw_info['email']
        }
      end

      extra do
        { :raw_info => raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get('account').parsed
      end
    end
  end
end
