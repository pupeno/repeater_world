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

RSpec.describe Repeater, type: :model do
  it "has latitude and longitude" do
    @repeater = build(:repeater)
    @repeater.location = nil
    expect(@repeater.latitude).to be(nil)
    expect(@repeater.longitude).to be(nil)
    @repeater.save!
    @repeater.reload
    expect(@repeater.latitude).to be(nil)
    expect(@repeater.longitude).to be(nil)

    @repeater.latitude = 1
    expect(@repeater.latitude).to eq(1)
    expect(@repeater.longitude).to eq(0)

    @repeater.longitude = 2
    expect(@repeater.latitude).to eq(1)
    expect(@repeater.longitude).to eq(2)
    @repeater.save
    @repeater.reload
    expect(@repeater.latitude).to eq(1)
    expect(@repeater.longitude).to eq(2)
  end

  context "A repeater" do
    before { @repeater = create(:repeater) }

    it "is readable" do
      expect(@repeater.to_s).to include(@repeater.class.name)
      expect(@repeater.to_s).to include(@repeater.id)
      expect(@repeater.to_s).to include(@repeater.name)
      expect(@repeater.to_s).to include(@repeater.call_sign)
    end

    it "has SEO friendly params" do
      expect(@repeater.to_param).to include(@repeater.call_sign.parameterize)
      expect(@repeater.to_param).to include(@repeater.name.parameterize)
    end

    it "has frequency helpers" do
      expect(@repeater.tx_frequency_in_mhz).to eq("144.9625MHz")
      expect(@repeater.rx_frequency).to eq(144362500)
      expect(@repeater.rx_frequency_in_mhz).to eq("144.3625MHz")
      expect(@repeater.rx_offset_in_khz).to eq("-600kHz")
      @repeater.rx_frequency = 145362500
      expect(@repeater.rx_offset_in_khz).to eq("+400kHz")
    end
  end
end

# == Schema Information
#
# Table name: repeaters
#
#  id                         :uuid             not null, primary key
#  address                    :string
#  altitude_agl               :integer
#  altitude_asl               :integer
#  band                       :string
#  bearing                    :string
#  call_sign                  :string
#  channel                    :string
#  dmr                        :boolean
#  dmr_color_code             :integer
#  dmr_network                :string
#  dstar                      :boolean
#  fm                         :boolean
#  fm_ctcss_tone              :decimal(, )
#  fm_tone_burst              :boolean
#  fm_tone_squelch            :boolean
#  fusion                     :boolean
#  grid_square                :string
#  keeper                     :string
#  locality                   :string
#  location                   :geography        point, 4326
#  name                       :string
#  notes                      :text
#  nxdn                       :boolean
#  operational                :boolean
#  p25                        :boolean
#  post_code                  :string
#  redistribution_limitations :string
#  region                     :string
#  rx_antenna                 :string
#  rx_antenna_polarization    :string
#  rx_frequency               :integer          not null
#  source                     :string
#  tetra                      :boolean
#  tx_antenna                 :string
#  tx_antenna_polarization    :string
#  tx_frequency               :integer          not null
#  tx_power                   :integer
#  utc_offset                 :string
#  web_site                   :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  country_id                 :string
#  external_id                :string
#
# Indexes
#
#  index_repeaters_on_call_sign   (call_sign)
#  index_repeaters_on_country_id  (country_id)
#  index_repeaters_on_location    (location) USING gist
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
