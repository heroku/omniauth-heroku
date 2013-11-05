require 'cgi'
require 'uri'
require 'oauth2'
require 'omniauth'
require 'timeout'
require 'securerandom'
require 'heroku-api'

module OmniAuth
  module Strategies
    # Vendored in from `omniauth-oauth2`, but with slight modifications to
    # allow request IDs to be passed through during the token phase so that the
    # OAuth 2 dance can be more easily debugged.
    class HerokuOAuth2 < OAuth2
      
      option :request_id, lambda { |env| nil }
      option :app_urls, false

      def credentials
        hash = super
        hash['token_type'] = access_token.params['token_type'] if access_token.params['token_type']
        hash
      end
      
      info do
        first_name, last_name = raw_info.delete('name').to_s.split(/\s+/, 2)
        
        if options.app_urls == true
          urls = heroku.get_apps.body.inject({}) do |apps, app|
            apps.merge(app['name'] => app['web_url'])
          end
        end
        
        {
          :name => raw_info.delete('name'),
          :email => raw_info.delete('email'),
          :nickname => raw_info.delete('id'),
          :first_name => first_name,
          :last_name => last_name,
          :location => nil,
          :description => nil,
          :image => nil,
          :phone => nil,
          :urls => urls || {}
        }
      end

      extra do
        { 'raw_info' => raw_info.merge(access_token.params) }
      end

      uid do
        access_token.params['user_id']
      end
      
      def raw_info
        @raw_info ||= heroku.get_user.body.tap do |body|
          body['verified_email'] = body['verified'] || body['confirmed']
        end
      end
      
      def heroku
        @heroku ||= ::Heroku::API.new(:api_key => access_token.token)
      end

      protected

      def build_access_token
        verifier = request.params['code']
        request_id_params = {}
        
        # inject a request ID if one is available
        if request_id = options.request_id.call(@env)
          request_id_params[:headers] = { "Request-Id" => request_id }
        end
        
        params = { :redirect_uri => callback_url }.merge(request_id_params).merge(token_params.to_hash(:symbolize_keys => true))
        
        created_access_token = client.auth_code.get_token(verifier, params)#, deep_symbolize(options.auth_token_params))
        
        if created_access_token.expired?
          access_token.refresh!(request_id_params)
        else
          created_access_token
        end
      end

    end
  end
end
