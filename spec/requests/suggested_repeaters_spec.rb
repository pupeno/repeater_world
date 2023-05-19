# Copyright 2023, Flexpoint Tech
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

RSpec.describe "/suggested_repeaters", type: :request do
  describe "GET /new" do
    it "renders a successful response" do
      get new_suggested_repeater_url
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    it "creates a new suggested repeater" do
      attributes = attributes_for(:suggested_repeater)
      expect {
        post suggested_repeaters_url, params: {suggested_repeater: attributes}
      }.to change(SuggestedRepeater, :count).by(1)
      expect(response).to redirect_to(new_suggested_repeater_url)
      suggested_repeater = SuggestedRepeater.last
      expect(suggested_repeater.call_sign).to eq(attributes[:call_sign])
    end
  end
end
