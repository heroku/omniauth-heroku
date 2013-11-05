require 'cgi'
require 'uri'
require 'oauth2'
require 'omniauth'
require 'timeout'
require 'securerandom'

module OmniAuth
  module Strategies
    # Vendored in from `omniauth-oauth2`, but with slight modifications to
    # allow request IDs to be passed through during the token phase so that the
    # OAuth 2 dance can be more easily debugged.
    class HerokuOAuth2
      include OmniAuth::Strategy

      args [:client_id, :client_secret]

      option :client_id, nil
      option :client_secret, nil
      option :client_options, {}
      option :authorize_params, {}
      option :authorize_options, [:scope]
      option :token_params, {}
      option :token_options, []
      option :provider_ignores_state, false
      option :request_id, lambda { |env| nil }

      attr_accessor :access_token

      def client
        ::OAuth2::Client.new(options.client_id, options.client_secret, deep_symbolize(options.client_options))
      end

      def callback_url
        full_host + script_name + callback_path
      end

      credentials do
        hash = {'token' => access_token.token}
        hash['refresh_token'] = access_token.refresh_token if access_token.expires? && access_token.refresh_token
        hash['expires_at'] = access_token.expires_at if access_token.expires?
        hash['expires'] = access_token.expires?
        hash['token_type'] = access_token.params['token_type'] if access_token.params['token_type']
        hash
      end

      extra do
        {'raw_info' => access_token.params}
      end

      uid do
        access_token.params['user_id']
      end

      def request_phase
        redirect client.auth_code.authorize_url({:redirect_uri => callback_url}.merge(authorize_params))
      end

      def authorize_params
        options.authorize_params[:state] = SecureRandom.hex(24)
        params = options.authorize_params.merge(options.authorize_options.inject({}){|h,k| h[k.to_sym] = options[k] if options[k]; h})
        if OmniAuth.config.test_mode
          @env ||= {}
          @env['rack.session'] ||= {}
        end
        session['omniauth.state'] = params[:state]
        params
      end

      def token_params
        options.token_params.merge(options.token_options.inject({}){|h,k| h[k.to_sym] = options[k] if options[k]; h})
      end

      def callback_phase
        if request.params['error'] || request.params['error_reason']
          raise CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri'])
        end
      # if !options.provider_ignores_state && (request.params['state'].to_s.empty? || request.params['state'] != session.delete('omniauth.state'))
      #   raise CallbackError.new(nil, :csrf_detected)
      # end

        self.access_token = build_access_token
        params = {}
        if request_id = options.request_id.call(@env)
          params.merge!(:headers => { "Request-Id" => request_id })
        end
        self.access_token = access_token.refresh!(params) if access_token.expired?

        super
      rescue ::OAuth2::Error, CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::MultiJson::DecodeError => e
        fail!(:invalid_response, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
        fail!(:timeout, e)
      rescue ::SocketError => e
        fail!(:failed_to_connect, e)
      end

      protected

      def deep_symbolize(hash)
        hash.inject({}) do |h, (k,v)|
          h[k.to_sym] = v.is_a?(Hash) ? deep_symbolize(v) : v
          h
        end
      end

      def build_access_token
        verifier = request.params['code']
        params = {:redirect_uri => callback_url}.
          merge(token_params.to_hash(:symbolize_keys => true))
        # inject a request ID if one is available
        if request_id = options.request_id.call(@env)
          params.merge!(:headers => { "Request-Id" => request_id })
        end
        client.auth_code.get_token(verifier, params)
      end

      # An error that is indicated in the OAuth 2.0 callback.
      # This could be a `redirect_uri_mismatch` or other
      class CallbackError < StandardError
        attr_accessor :error, :error_reason, :error_uri

        def initialize(error, error_reason=nil, error_uri=nil)
          self.error = error
          self.error_reason = error_reason
          self.error_uri = error_uri
        end
      end
    end
  end
end
