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

RSpec.describe "/api/next/repeaters", type: :request do
  context "With some repeaters" do
    before(:all) do
      Repeater.destroy_all
      create(:repeater, name: "23CM FM", fm: true, band: Repeater::BAND_23CM, latitude: 0, longitude: 0.07, location: "POINT(0 0.07)")
      create(:repeater, name: "70CM FM", fm: true, band: Repeater::BAND_70CM, latitude: 0, longitude: 0.13, location: "POINT(0 0.13)")
      create(:repeater, name: "2M FM", fm: true, band: Repeater::BAND_2M, latitude: 0, longitude: 1.4, location: "POINT(0 1.4)")
      create(:repeater, name: "4M FM", fm: true, band: Repeater::BAND_4M, latitude: 0, longitude: 2, location: "POINT(0 2)")
      create(:repeater, name: "23CM D-Star", dstar: true, band: Repeater::BAND_23CM)
      create(:repeater, name: "70CM Fusion", fusion: true, band: Repeater::BAND_70CM)
      create(:repeater, name: "2M DMR", dmr: true, band: Repeater::BAND_2M)
      create(:repeater, name: "4M NXDN", nxdn: true, band: Repeater::BAND_4M)
    end

    it "creates a json output" do
      get api_next_repeaters_url(format: :json)
      expect(response).to be_successful
      body = JSON.parse(response.body)
      expect(body.size).to eq(8)
      # TODO: write better assertions.
    end

    it "creates a csv output" do
      get api_next_repeaters_url(format: :csv)
      expect(response).to be_successful
      body = CSV.parse(response.body)
      expect(body.size).to eq(9)
      # TODO: write better assertions.
    end
  end
end
