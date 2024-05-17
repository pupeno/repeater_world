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
      expect(@repeater.to_param).to include(@repeater.id)
      expect(@repeater.to_param).to include(@repeater.call_sign.parameterize)
      expect(@repeater.to_param).to include(@repeater.name.parameterize)
      @repeater.name = nil
      @repeater.call_sign = nil
      expect(@repeater.to_param).to include(@repeater.id)
    end

    it "fixes web site" do
      @repeater.web_site = "example.com"
      expect(@repeater.web_site).to eq("http://example.com")
      @repeater.web_site = nil
      expect(@repeater.web_site).to be(nil)
      @repeater.web_site = ""
      expect(@repeater.web_site).to eq("")
      @repeater.web_site = "  "
      expect(@repeater.web_site).to eq("  ")
      @repeater.web_site = "http:example.com"
      expect(@repeater.web_site).to eq("http://http:example.com") # Can't save everyone.
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
#  dstar_port                 :string
#  echo_link                  :boolean
#  echo_link_node_number      :integer
#  fm                         :boolean
#  fm_bandwidth               :string
#  fm_ctcss_tone              :decimal(, )
#  fm_tone_burst              :boolean
#  fm_tone_squelch            :boolean
#  fusion                     :boolean
#  geocoded_address           :string
#  geocoded_at                :datetime
#  geocoded_by                :string
#  geocoded_locality          :string
#  geocoded_post_code         :string
#  geocoded_region            :string
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
#  rx_frequency               :bigint           not null
#  source                     :string
#  tetra                      :boolean
#  tx_antenna                 :string
#  tx_antenna_polarization    :string
#  tx_frequency               :bigint           not null
#  tx_power                   :integer
#  utc_offset                 :string
#  web_site                   :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  country_id                 :string
#  external_id                :string
#  geocoded_country_id        :string
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
