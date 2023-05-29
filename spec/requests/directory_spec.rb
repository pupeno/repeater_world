# Copyright 2023, Pablo Fernandez
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

RSpec.describe "/directory", type: :request do
  it "shows a list of countries" do
    get directory_url
    expect(response).to be_successful
    expect(response.body).to include("Directory")
    expect(response.body).to include("United Kingdom")
    expect(response.body).to include("United States")
    expect(response.body).to include("Canada")
    expect(response.body).to include("Mexico")
  end

  context "with repeaters" do
    include_context "repeaters"

    it "shows repeaters in the uk" do
      get directory_by_country_url("gb")
      expect(response).to be_successful
      expect(response.body).to include("Repeaters in United Kingdom")
      expect(response.body).to include("GB3CN")
      expect(response.body).not_to include("JP0AA")
    end
  end
end
