require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Heroku < OmniAuth::Strategies::OAuth2
      BaseAuthUrl = ENV["HEROKU_AUTH_URL"] || "https://api.heroku.com"

      option :client_options, {
        :site => BaseAuthUrl,
        :authorize_url => "#{BaseAuthUrl}/oauth/authorize",
        :token_url => "#{BaseAuthUrl}/oauth/token"
      }

      def request_phase
        super
      end

      uid { raw_info['id'] }

      info do
        { 'email' => raw_info['email'] }
      end

      extra do
        { 'raw_info' => raw_info }
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('/account').parsed
      end
    end
  end
end
