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
          'name' => display_name,
          'email' => raw_info['email']
        }
      end

      extra do
        { :raw_info => raw_info }
      end

      def display_name
        (raw_info['name'].nil? || raw_info['name'].empty?) ? raw_info['email'] : raw_info['name']
      end

      def raw_info
        @raw_info ||= access_token.get('account').parsed
      end
    end
  end
end
