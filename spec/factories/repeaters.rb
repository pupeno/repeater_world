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

FactoryBot.define do
  factory :repeater do
    call_sign { "BL4NK" }
    sequence(:name) { |n| "Repeater #{call_sign}".strip }
    band { Repeater::BAND_2M }
    tx_frequency { 144_962_500 } # VHF, maybe dispatch on the band for different frequencies?
    rx_frequency { tx_frequency - 600_000 } # VHF, maybe dispatch on the band for different frequencies?
    country_id { "gb" }

    trait :explicit_modes do
      after(:build) do |repeater|
        repeater.operational = false unless repeater.operational?
        repeater.fm = false unless repeater.fm?
        repeater.fm_tone_burst = false unless repeater.fm_tone_burst?
        repeater.fm_tone_squelch = false unless repeater.fm_tone_squelch?
        repeater.dstar = false unless repeater.dstar?
        repeater.fusion = false unless repeater.fusion?
        repeater.dmr = false unless repeater.dmr?
        repeater.nxdn = false unless repeater.nxdn?
        repeater.p25 = false unless repeater.p25?
        repeater.tetra = false unless repeater.tetra
      end
    end

    trait :full do
      call_sign { "FU11" }
      sequence(:name) { |n| "Repeater #{call_sign}".strip }
      keeper { "K3EPR" }
      operational { true }

      channel { "channel" }
      fm { true }
      fm_ctcss_tone { Repeater::CTCSS_TONES.first }
      fm_tone_burst { true }
      fm_tone_squelch { true }
      fm_bandwidth { Repeater::FM_WIDE }
      dstar { true }
      dstar_port { "C" }
      fusion { true }
      dmr { true }
      dmr_color_code { 1 }
      dmr_network { "Brandmeister" }
      nxdn { true }
      p25 { true }
      tetra { true }

      latitude { 51.74 }
      longitude { -3.42 }
      address { "address" }
      locality { "city" }
      region { "region" }
      post_code { "PC" }
      grid_square { "IO81HR" }
      altitude_agl { 150 }
      altitude_asl { 200 }
      utc_offset { "05:00" }

      tx_antenna { "tx_antenna" }
      tx_antenna_polarization { "V" }
      tx_power { 50 }
      rx_antenna { "rx_antenna" }
      rx_antenna_polarization { "V" }
      bearing { "bearing" }

      notes { "Notes" }
      redistribution_limitations { "redistribution_limitations" }
      source { "source" }
      web_site { "https://website" }
      external_id { "external id" }
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
