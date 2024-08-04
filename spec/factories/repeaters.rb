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

FactoryBot.define do
  factory :repeater do
    call_sign { "BL4NK" }
    sequence(:name) { |n| "Repeater #{call_sign}".strip }
    band { Repeater::BAND_2M }
    tx_frequency { 144_962_500 } # VHF, maybe dispatch on the band for different frequencies?
    rx_frequency { tx_frequency - 600_000 } # VHF, maybe dispatch on the band for different frequencies?
    country_id { "gb" }

    trait :populate_input_coordinates do
      after(:build) do |repeater|
        repeater.input_address ||= repeater.address
        repeater.input_locality ||= repeater.locality
        repeater.input_region ||= repeater.region
        repeater.input_post_code ||= repeater.post_code
        repeater.input_country_id ||= repeater.country_id
        repeater.input_coordinates ||= repeater.coordinates
        repeater.input_grid_square ||= repeater.grid_square
      end
    end

    trait :explicit_modes do
      after(:build) do |repeater|
        repeater.fm = false unless repeater.fm?
        repeater.fm_tone_burst = false unless repeater.fm_tone_burst?
        repeater.fm_tone_squelch = false unless repeater.fm_tone_squelch?
        repeater.m17 = false unless repeater.m17?
        repeater.dstar = false unless repeater.dstar?
        repeater.fusion = false unless repeater.fusion?
        repeater.dmr = false unless repeater.dmr?
        repeater.nxdn = false unless repeater.nxdn?
        repeater.p25 = false unless repeater.p25?
        repeater.tetra = false unless repeater.tetra
      end
    end

    trait :full do
      populate_input_coordinates

      call_sign { "FU11" }
      sequence(:name) { |n| "Repeater #{call_sign}".strip }
      keeper { "K3EPR" }
      operational { true }

      channel { "channel" }
      fm { true }
      fm_ctcss_tone { Repeater::CTCSS_TONES.first }
      fm_tone_burst { true }
      fm_tone_squelch { true }
      m17 { true }
      m17_can { 5 }
      m17_reflector_name { "m17 reflector" }
      dstar { true }
      dstar_port { "C" }
      fusion { true }
      dmr { true }
      dmr_color_code { 1 }
      dmr_network { "Brandmeister" }
      nxdn { true }
      p25 { true }
      tetra { true }
      bandwidth { Repeater::FM_WIDE }

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
#  bandwidth                  :integer
#  bearing                    :string
#  call_sign                  :string
#  channel                    :string
#  coordinates                :geography        point, 4326
#  dmr                        :boolean
#  dmr_color_code             :integer
#  dmr_network                :string
#  dstar                      :boolean
#  dstar_port                 :string
#  echo_link                  :boolean
#  echo_link_node_number      :integer
#  fm                         :boolean
#  fm_ctcss_tone              :decimal(, )
#  fm_tone_burst              :boolean
#  fm_tone_squelch            :boolean
#  fusion                     :boolean
#  geocoded_at                :datetime
#  geocoded_by                :string
#  grid_square                :string
#  input_address              :string
#  input_coordinates          :geography        point, 4326
#  input_grid_square          :string
#  input_locality             :string
#  input_post_code            :string
#  input_region               :string
#  irlp                       :boolean
#  irlp_node_number           :integer
#  keeper                     :string
#  locality                   :string
#  m17                        :boolean
#  m17_can                    :integer
#  m17_reflector_name         :string
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
#  slug                       :string           not null
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
#  input_country_id           :string
#  wires_x_node_id            :string
#
# Indexes
#
#  index_repeaters_on_call_sign          (call_sign)
#  index_repeaters_on_coordinates        (coordinates) USING gist
#  index_repeaters_on_country_id         (country_id)
#  index_repeaters_on_input_coordinates  (input_coordinates)
#  index_repeaters_on_input_country_id   (input_country_id)
#  index_repeaters_on_slug               (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (input_country_id => countries.id)
#
