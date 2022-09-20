require "rails_helper"

RSpec.describe "Statics", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/"
      expect(response).to have_http_status(:success)
    end
  end

  it "shows a backend failure" do
    expect { get "/fail" }.to raise_error(/Bogus/)
  end

  it "shows a frontend failure" do
    get "/fail-fe"
    expect(response).to be_successful
  end

  it "shows a background failure" do
    get "/fail-bg"
    expect(response).to be_successful
  end

  it "shows a 404" do
    method = Rails.application.method(:env_config)

    expect(Rails.application).to receive(:env_config).with(no_args) do
      method.call.merge(
        "action_dispatch.show_exceptions" => true,
        "action_dispatch.show_detailed_exceptions" => false,
        "consider_all_requests_local" => false
      )
    end
    get "/a-url-that-doesnt-exist"
    expect(response).to have_http_status(:not_found)
    expect(response.body).to include("Page not found")
  end
end
