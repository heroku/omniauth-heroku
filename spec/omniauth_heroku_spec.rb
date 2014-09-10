require "spec_helper"

describe OmniAuth::Strategies::Heroku do
  it "works" do
    get "/"
    expect(last_response.body).to eq("ohhai")
  end
end