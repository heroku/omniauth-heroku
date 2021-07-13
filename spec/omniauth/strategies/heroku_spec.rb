RSpec.describe OmniAuth::Strategies::Heroku do
  let(:strategy) { described_class.new(app, "OAuthId", "OAuthSecret") }
  let(:app) { ->(_env) { [200, {}, ["Hello."]] } }

  describe "client options" do
    let(:client) { strategy.client }

    it "defaults site" do
      expect(client.site).to eq("https://id.heroku.com")
    end

    it "defaults authorize url" do
      expect(client.authorize_url).to eq("https://id.heroku.com/oauth/authorize")
    end

    it "defaults token url" do
      expect(client.token_url).to eq("https://id.heroku.com/oauth/token")
    end

    # NOTE: Due to the design of the base OmniAuth::Strategy we don't have a good way to test
    # overriding the defaults via ENV Vars. But we've supported overriding that way since...
    # forever, basically, we still need to support it until we make it a clear breaking change.
    # So we'll ignore that case, I guess 🤷
  end

  describe "#authorize_params" do
    around do |example|
      OmniAuth.config.test_mode = true
      example.call
      OmniAuth.config.test_mode = false
    end

    it "does not add a default scope" do
      expect(strategy.authorize_params).not_to have_key("scope")
    end

    it "can use a static :scope option" do
      strategy = described_class.new(app, "OAuthId", "OAuthSecret", scope: "boring-scope")

      expect(strategy.authorize_params.fetch("scope")).to eq("boring-scope")
    end

    it "can dynamically determine the :scope option" do
      strategy = described_class.new(app, "OAuthId", "OAuthSecret", scope: ->(_env) { "magic-scope" })

      expect(strategy.authorize_params.fetch("scope")).to eq("magic-scope")
    end
  end

  describe "#extra" do
    let(:token) { "some-uuid" }

    it "does not fetch account info by default" do
      expect(strategy.extra).to be_empty
    end

    it "fetches account info when :fetch_info option is true" do
      strategy = described_class.new(app, "OAuthId", "OAuthSecret", fetch_info: true)
      strategy.access_token = OpenStruct.new(token: token)

      account_info = {"email" => "john@example.org", "name" => "John"}

      stub_request(:get, "https://api.heroku.com/account")
        .with(headers: {"Authorization" => "Bearer #{token}"})
        .to_return(body: MultiJson.encode(account_info))

      expect(strategy.extra).to include(account_info)
    end
  end

  describe "#info" do
    let(:token) { "some-uuid" }

    it "does not fetch account info by default" do
      expect(strategy.info).to eq(name: "Heroku user")
    end

    it "fetches account info when :fetch_info option is true" do
      strategy = described_class.new(app, "OAuthId", "OAuthSecret", fetch_info: true)
      strategy.access_token = OpenStruct.new(token: token)

      account_info = {"email" => "john@example.org", "name" => "John"}

      stub_request(:get, "https://api.heroku.com/account")
        .with(headers: {"Authorization" => "Bearer #{token}"})
        .to_return(body: MultiJson.encode(account_info))

      aggregate_failures do
        expect(strategy.info).to include(name: "John", email: "john@example.org")
        expect(strategy.info.fetch(:image)).to match(%r{secure\.gravatar\.com/avatar/.+})
      end
    end
  end

  describe "#uid" do
    it "is the user_id from the Access Token" do
      strategy.access_token = OpenStruct.new(params: {"user_id" => "some-user-id"})

      expect(strategy.uid).to eq("some-user-id")
    end
  end

  describe "error handling" do
    let(:env) {
      {
        "REQUEST_METHOD" => "POST",
        "PATH_INFO" => "/auth/heroku",
        "rack.session" => {},
        "rack.input" => StringIO.new("test=true")
      }
    }

    around do |example|
      # OmniAuth >= 2.0.0 has a configurable request validations phase
      # used to validate XSRF, etc... When that's available we'll turn
      # it off for this set of tests since we're trying to test our own
      # validations, which would run after the request validation. On
      # older versions it didn't exist, so don't worry about it!
      if defined?(OmniAuth.config.request_validation_phase)
        phase = OmniAuth.config.request_validation_phase
        OmniAuth.config.request_validation_phase = false
        example.call
        OmniAuth.config.request_validation_phase = phase
      else
        example.call
      end
    end

    it "fails when client_id is not provided" do
      strategy = described_class.new(app, nil, "ClientSecret")

      status, headers, _body = strategy.call(env)
      redirect = URI.parse(headers.fetch("Location"))

      aggregate_failures do
        expect(status).to eq(302)
        expect(redirect.path).to eq("/auth/failure")
        expect(env.fetch("omniauth.error.type")).to eq(:missing_client_id)
      end
    end

    it "fails when client_id is empty" do
      strategy = described_class.new(app, "", "ClientSecret")

      status, headers, _body = strategy.call(env)
      redirect = URI.parse(headers.fetch("Location"))

      aggregate_failures do
        expect(status).to eq(302)
        expect(redirect.path).to eq("/auth/failure")
        expect(env.fetch("omniauth.error.type")).to eq(:missing_client_id)
      end
    end

    it "fails when client_secret is not provided" do
      strategy = described_class.new(app, "ClientId", nil)

      status, headers, _body = strategy.call(env)
      redirect = URI.parse(headers.fetch("Location"))

      aggregate_failures do
        expect(status).to eq(302)
        expect(redirect.path).to eq("/auth/failure")
        expect(env.fetch("omniauth.error.type")).to eq(:missing_client_secret)
      end
    end

    it "fails when client_secret is empty" do
      strategy = described_class.new(app, "ClientId", "")

      status, headers, _body = strategy.call(env)
      redirect = URI.parse(headers.fetch("Location"))

      aggregate_failures do
        expect(status).to eq(302)
        expect(redirect.path).to eq("/auth/failure")
        expect(env.fetch("omniauth.error.type")).to eq(:missing_client_secret)
      end
    end
  end
end
