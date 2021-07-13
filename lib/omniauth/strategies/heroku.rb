# frozen_string_literal: true

require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Heroku < OmniAuth::Strategies::OAuth2
      # This style of overriding the default means it can only be done when the class is loaded.
      # Which is problematic for testing, and a bit against the grain of how the base class
      # expects this to work, where consumers would explicitly override by passing in the option.
      AUTH_URL = ENV.fetch("HEROKU_AUTH_URL", "https://id.heroku.com")
      private_constant :AUTH_URL

      option(:client_options, {
        site: AUTH_URL,
        authorize_url: "#{AUTH_URL}/oauth/authorize",
        token_url: "#{AUTH_URL}/oauth/token"
      })

      # Configure whether we make another API call to Heroku to fetch
      # additional account info like the real user name and email
      option :fetch_info, false

      uid do
        access_token.params["user_id"]
      end

      info do
        if options.fetch_info
          email_hash = Digest::MD5.hexdigest(account_info["email"].to_s)
          image_url = "https://secure.gravatar.com/avatar/#{email_hash}.png?d=#{DEFAULT_IMAGE_URL}"

          {
            name: account_info["name"],
            email: account_info["email"],
            image: image_url
          }
        else
          {name: "Heroku user"} # only mandatory field
        end
      end

      extra do
        if options.fetch_info
          account_info
        else
          {}
        end
      end

      # override method in OmniAuth::Strategies::OAuth2 to error
      # when we don't have a client_id or secret:
      def request_phase
        if missing_client_id?
          fail!(:missing_client_id)
        elsif missing_client_secret?
          fail!(:missing_client_secret)
        else
          super
        end
      end

      private

      DEFAULT_API_URL = "https://api.heroku.com"
      private_constant :DEFAULT_API_URL

      DEFAULT_IMAGE_URL = "https://dashboard.heroku.com/ninja-avatar-48x48.png"
      private_constant :DEFAULT_IMAGE_URL

      def account_info
        @account_info ||= MultiJson.decode(heroku_api.get("/account").body)
      end

      def api_url
        @api_url ||= ENV.fetch("HEROKU_API_URL", DEFAULT_API_URL)
      end

      def heroku_api
        @heroku_api ||= Faraday.new(
          url: api_url,
          headers: {
            "Accept" => "application/vnd.heroku+json; version=3",
            "Authorization" => "Bearer #{access_token.token}"
          }
        )
      end

      def missing_client_id?
        [nil, ""].include?(options.client_id)
      end

      def missing_client_secret?
        [nil, ""].include?(options.client_secret)
      end
    end
  end
end
