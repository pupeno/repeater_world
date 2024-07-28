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

RSpec.describe "/api/next/repeaters", type: :request do
  context "With some repeaters" do
    before(:all) do
      Repeater.destroy_all
      create(:repeater, name: "23CM FM", fm: true, band: Repeater::BAND_23CM, tx_frequency: 1240_000_000, rx_frequency: 1240_000_000, input_latitude: 0.07, input_longitude: 0)
      create(:repeater, name: "70CM FM", fm: true, band: Repeater::BAND_70CM, tx_frequency: 420_000_000, rx_frequency: 420_000_000, input_latitude: 0.13, input_longitude: 0)
      create(:repeater, name: "2M FM", fm: true, band: Repeater::BAND_2M, tx_frequency: 144_000_000, rx_frequency: 144_000_000, input_latitude: 1.4, input_longitude: 0)
      create(:repeater, name: "4M FM", fm: true, band: Repeater::BAND_4M, tx_frequency: 70_000_000, rx_frequency: 70_000_000, input_latitude: 2, input_longitude: 0)
      create(:repeater, name: "23CM D-Star", dstar: true, band: Repeater::BAND_23CM, tx_frequency: 1240_000_000, rx_frequency: 1240_000_000)
      create(:repeater, name: "70CM Fusion", fusion: true, band: Repeater::BAND_70CM, tx_frequency: 420_000_000, rx_frequency: 420_000_000)
      create(:repeater, name: "2M DMR", dmr: true, band: Repeater::BAND_2M, tx_frequency: 144_000_000, rx_frequency: 144_000_000)
      create(:repeater, name: "4M NXDN", nxdn: true, band: Repeater::BAND_4M, tx_frequency: 70_000_000, rx_frequency: 70_000_000)
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
