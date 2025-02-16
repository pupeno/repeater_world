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
      fm_dcs_code { nil }
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
