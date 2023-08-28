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

RSpec.shared_context "repeaters" do
  before(:context) do
    Repeater.delete_all

    # FM repeater with CTCSS
    create(:repeater, :explicit_modes,
      name: "Newcastle Emlyn", call_sign: "GB3CN", band: "2m", channel: "RV55", keeper: "GW6JSO", operational: true,
      tx_frequency: 145_687_500,
      rx_frequency: 145_087_500,
      fm: true, fm_ctcss_tone: 94.8,
      grid_square: "IO71TX", latitude: 51.99, longitude: -4.4,
      locality: "Newcastle Emlyn", region: "Wales & Marches", post_code: "SA44", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net", redistribution_limitations: "https://repeater.world/ukrepeater-net")

    # FM repeater without CTCSS, and Fusion
    create(:repeater, :explicit_modes,
      name: "Weymouth", call_sign: "GB3DR", band: "2m", channel: "RV59", keeper: "G3VPF", operational: nil,
      tx_frequency: 145_737_500,
      rx_frequency: 145_137_500,
      fm: true, fm_tone_burst: true, fusion: true,
      grid_square: "IO80SN", latitude: 50.55, longitude: -2.44,
      locality: "Weymouth", region: "South West, England", post_code: "DT5", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # FM and D-Star repeater.
    create(:repeater, :explicit_modes,
      name: "Herne Bay", call_sign: "GB7IC-C", band: "2m", channel: "RV53", keeper: "G4TKR", operational: true,
      tx_frequency: 145_662_500,
      rx_frequency: 145_062_500,
      fm: true, dstar: true,
      grid_square: "JO01NI", latitude: 51.36, longitude: 1.15,
      locality: "Herne Bay", region: "South East, England", post_code: "CT6", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # D-Star repeater only.
    create(:repeater, :explicit_modes,
      name: "Marlborough", call_sign: "GB7AE", band: "70cm", channel: "DVU34", keeper: "M1CJE", operational: true,
      tx_frequency: 439_425_000,
      rx_frequency: 430_425_000,
      dstar: true,
      grid_square: "IO91CJ", latitude: 51.42, longitude: -1.76,
      locality: "Marlborough", region: "South West, England", post_code: "SN8", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # FM, D-Star, Fusion, DMR and NXDN repeater.
    create(:repeater, :explicit_modes,
      name: "Derby", call_sign: "GB7DC", band: "70cm", channel: "RU70", keeper: "G7NPW", operational: nil,
      tx_frequency: 430_875_000,
      rx_frequency: 438_475_000,
      fm: true, fm_ctcss_tone: 71.9,
      dstar: true,
      fusion: true,
      dmr: true, dmr_color_code: 1, dmr_network: "BRANDMEISTER",
      nxdn: true,
      grid_square: "IO92GW", latitude: 52.9, longitude: -1.4,
      locality: "Derby", region: "Midlands, England", post_code: "DE21", country_id: "gb",
      utc_offset: nil, source: "ukrepeater.net", notes: "Reduced output.")

    # Fusion only repeater.
    create(:repeater, :explicit_modes,
      name: "Perth", call_sign: "GB3SF", band: "2m", channel: "RV50", keeper: "GM3NFO", operational: true,
      tx_frequency: 145_625_000,
      rx_frequency: 145_025_000,
      fusion: true,
      grid_square: "IO86HK", latitude: 56.5, longitude: -3.4,
      locality: "Perth", region: "Scotland", post_code: "PH2", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # DMR repeater.
    create(:repeater, :explicit_modes,
      name: "Cleobury North", call_sign: "GB3BX", band: "2m", channel: "RV54", keeper: "G4VZO", operational: true,
      tx_frequency: 145_675_000,
      rx_frequency: 145_075_000,
      dmr: true, dmr_color_code: 13, dmr_network: "SALOP DMR",
      grid_square: "IO82QL", latitude: 52.5, longitude: -2.6,
      locality: "Cleobury North", region: "Wales & Marches", post_code: "SY7", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # Non-2m-70cm repeater.
    create(:repeater, :explicit_modes,
      name: "Amersham", call_sign: "GB3AM", band: "6m", channel: "R50-13", keeper: "M0ZPU", operational: true,
      tx_frequency: 50840000,
      rx_frequency: 51340000,
      fm: true, fm_ctcss_tone: 77,
      grid_square: "IO91QP", latitude: 51.65, longitude: -0.62,
      locality: "Amersham", region: "South West, England", post_code: "HP7", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # Non operational repeater on fm, dstar, fusion and dmr.
    create(:repeater, :explicit_modes,
      name: "Hawick", call_sign: "GB3AI", band: "2m", channel: "RV59", keeper: "GM8SJP", operational: false,
      tx_frequency: 145_737_500,
      rx_frequency: 145_137_500,
      fm: true, fm_ctcss_tone: 0.1035e3, fm_tone_squelch: nil,
      dstar: true,
      fusion: true,
      dmr: true, dmr_color_code: 3, dmr_network: "DV Scotland Phoenix",
      grid_square: "IO85PK", latitude: 55.4, longitude: -2.7,
      locality: "Hawick", region: "Scotland", post_code: "TD9", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # Japanese D-Star repeaters.
    create(:repeater, :explicit_modes,
      name: "Made up", call_sign: "JP0AA", band: "70cm", keeper: "JP0ZZ", operational: true,
      tx_frequency: 439_420_000,
      rx_frequency: 430_420_000,
      dstar: true,
      country_id: "jp")
    create(:repeater, :explicit_modes,
      name: "Made up", call_sign: "JP0AA", band: "23cm", keeper: "JP0ZZ", operational: true,
      tx_frequency: 129_790_0000,
      rx_frequency: 129_790_0000,
      dstar: true,
      country_id: "jp")

    # Blank repeaters
    create(:repeater)
    create(:repeater, fm: true, tx_frequency: 144_970_000)

    # Full repeater
    create(:repeater, :full)
  end

  after(:context) do
    Repeater.delete_all
  end
end
