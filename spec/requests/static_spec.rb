# Copyright 2023-2024, Pablo Fernandez
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Repeater World is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
# <https://www.gnu.org/licenses/>.

require "rails_helper"

RSpec.describe "Statics", type: :request do
  it "renders the home page" do
    get "/"
    expect(response).to be_successful
  end

  it "renders values" do
    get "/values"
    expect(response).to be_successful
  end

  it "renders data-limitations/ukrepeater-net" do
    get "/data-limitations/ukrepeater-net"
    expect(response).to be_successful
  end

  it "renders data-limitations/sral-fi" do
    get "/data-limitations/sral-fi"
    expect(response).to be_successful
  end

  it "renders crawler" do
    get "/crawler"
    expect(response).to be_successful
  end

  it "renders privacy-policy" do
    get "/privacy-policy"
    expect(response).to be_successful
  end

  it "renders cookie-policy" do
    get "/cookie-policy"
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

  context "with a bunch of repeaters" do
    include_context "repeaters"

    it "shows a sitemap" do
      get "/sitemap.xml"
      expect(response).to be_successful
      expect(response.body).to include(root_url)
      expect(response.body).to include(repeater_url(Repeater.first))
    end
  end

  it "shows a backend failure" do
    get "/fail"
    expect(response).not_to be_successful
    expect(response).to have_http_status(:internal_server_error)
  end

  it "shows a frontend failure" do
    get "/fail-fe"
    expect(response).to be_successful
  end

  it "shows a background failure" do
    get "/fail-bg"
    expect(response).to be_successful
  end
end
