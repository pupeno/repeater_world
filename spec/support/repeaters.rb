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
    create(:repeater,
      name: "Newcastle Emlyn", call_sign: "GB3CN", band: "2m", channel: "RV55", keeper: "GW6JSO",
      operational: true, notes: nil,
      tx_frequency: 145687500,
      rx_frequency: 145087500,
      fm: true, fm_ctcss_tone: 94.8, tone_sql: false,
      dstar: false,
      fusion: false,
      dmr: false, dmr_color_code: nil, dmr_network: nil,
      nxdn: nil,
      grid_square: "IO71TX", latitude: 51.99, longitude: -4.4,
      locality: "Newcastle Emlyn", region: "Wales & Marches", post_code: "SA44", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net", redistribution_limitations: "https://repeater.world/ukrepeater-net")

    # FM repeater without CTCSS
    create(:repeater,
      name: "Weymouth", call_sign: "GB3DR", band: "2m", channel: "RV59", keeper: "G3VPF",
      operational: true, notes: nil,
      tx_frequency: 145737500,
      rx_frequency: 145137500,
      fm: true, fm_tone_burst: true, fm_ctcss_tone: nil, tone_sql: nil,
      dstar: false,
      fusion: true,
      dmr: false, dmr_color_code: nil, dmr_network: nil,
      nxdn: nil,
      grid_square: "IO80SN", latitude: 50.55, longitude: -2.44,
      locality: "Weymouth", region: "South West, England", post_code: "DT5", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # FM and D-Star repeater.
    create(:repeater,
      name: "Herne Bay", call_sign: "GB7IC-C", band: "2m", channel: "RV53", keeper: "G4TKR",
      operational: true, notes: nil,
      tx_frequency: 145662500,
      rx_frequency: 145062500,
      fm: true, fm_tone_burst: nil, fm_ctcss_tone: nil, tone_sql: nil,
      dstar: true,
      fusion: false,
      dmr: false, dmr_color_code: nil, dmr_network: nil,
      nxdn: nil,
      grid_square: "JO01NI", latitude: 51.36, longitude: 1.15,
      locality: "Herne Bay", region: "South East, England", post_code: "CT6", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # D-Star repeater only.
    create(:repeater,
      name: "Marlborough", call_sign: "GB7AE", band: "70cm", channel: "DVU34", keeper: "M1CJE",
      operational: true, notes: nil,
      tx_frequency: 439425000,
      rx_frequency: 430425000,
      fm: false, fm_tone_burst: nil, fm_ctcss_tone: nil, tone_sql: nil,
      dstar: true,
      fusion: false,
      dmr: false, dmr_color_code: nil, dmr_network: nil, nxdn: nil,
      grid_square: "IO91CJ", latitude: 51.42, longitude: -1.76,
      locality: "Marlborough", region: "South West, England", post_code: "SN8", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # FM and Fusion repeater.
    create(:repeater,
      name: "Derby", call_sign: "GB7DC", band: "70cm", channel: "RU70", keeper: "G7NPW",
      operational: true, notes: "Reduced output.",
      tx_frequency: 430875000,
      rx_frequency: 438475000,
      fm: true, fm_ctcss_tone: 71.9, tone_sql: false,
      dstar: true,
      fusion: true,
      dmr: true, dmr_color_code: 1, dmr_network: "BRANDMEISTER",
      nxdn: true,
      grid_square: "IO92GW", latitude: 52.9, longitude: -1.4,
      locality: "Derby", region: "Midlands, England", post_code: "DE21", country_id: "gb",
      utc_offset: nil, source: "ukrepeater.net")

    # Fusion only repeater.
    create(:repeater,
      name: "Perth", call_sign: "GB3SF", band: "2m", channel: "RV50", keeper: "GM3NFO",
      operational: true, notes: nil,
      tx_frequency: 145625000,
      rx_frequency: 145025000,
      fm: false, fm_tone_burst: nil, fm_ctcss_tone: nil, tone_sql: nil,
      dstar: false,
      fusion: true,
      dmr: false, dmr_color_code: nil, dmr_network: nil,
      nxdn: nil,
      grid_square: "IO86HK", latitude: 56.5, longitude: -3.4,
      locality: "Perth", region: "Scotland", post_code: "PH2", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # DMR and nxdn repeater.
    create(:repeater,
      name: "Cleobury North", call_sign: "GB3BX", band: "2m", channel: "RV54", keeper: "G4VZO",
      operational: true, notes: "Reduced output.",
      tx_frequency: 145675000,
      rx_frequency: 145075000,
      fm: false, fm_tone_burst: nil, fm_ctcss_tone: nil, tone_sql: nil,
      dstar: false,
      fusion: false,
      dmr: true, dmr_color_code: 13, dmr_network: "SALOP DMR",
      nxdn: nil,
      grid_square: "IO82QL", latitude: 52.5, longitude: -2.6,
      locality: "Cleobury North", region: "Wales & Marches", post_code: "SY7", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # Non-2m-70cm repeater.
    create(:repeater,
      name: "Amersham", call_sign: "GB3AM", band: "6m", channel: "R50-13", keeper: "M0ZPU",
      operational: true, notes: nil,
      tx_frequency: 50840000,
      rx_frequency: 51340000,
      fm: true, fm_ctcss_tone: 77, tone_sql: false,
      dstar: false,
      fusion: false,
      dmr: false, dmr_color_code: nil, dmr_network: nil,
      nxdn: nil,
      grid_square: "IO91QP", latitude: 51.65, longitude: -0.62,
      locality: "Amersham", region: "South West, England", post_code: "HP7", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # Non operational repeater on fm, dstar, fusion and dmr.
    create(:repeater,
      name: "Hawick", call_sign: "GB3AI", band: "2m", channel: "RV59", keeper: "GM8SJP",
      operational: false, notes: nil,
      tx_frequency: 145737500,
      rx_frequency: 145137500,
      fm: true, fm_ctcss_tone: 0.1035e3, tone_sql: nil,
      dstar: true,
      fusion: true,
      dmr: true, dmr_color_code: 3, dmr_network: "DV Scotland Phoenix",
      nxdn: nil,
      grid_square: "IO85PK", latitude: 55.4, longitude: -2.7,
      locality: "Hawick", region: "Scotland", post_code: "TD9", country_id: "gb",
      utc_offset: "0:00", source: "ukrepeater.net")

    # Japanese D-Star repeaters.
    create(:repeater,
      name: "Made up", call_sign: "JP0AA", band: "70cm", keeper: "JP0ZZ",
      operational: true,
      tx_frequency: 439420000,
      rx_frequency: 430420000,
      fm: false, fm_tone_burst: nil, fm_ctcss_tone: nil, tone_sql: nil,
      dstar: true,
      fusion: false,
      dmr: false, dmr_color_code: nil, dmr_network: nil, nxdn: nil,
      country_id: "jp")
    create(:repeater,
      name: "Made up", call_sign: "JP0AA", band: "23cm", keeper: "JP0ZZ",
      operational: true,
      tx_frequency: 1297900000,
      rx_frequency: 1297900000,
      fm: false, fm_tone_burst: nil, fm_ctcss_tone: nil, tone_sql: nil,
      dstar: true,
      fusion: false,
      dmr: false, dmr_color_code: nil, dmr_network: nil, nxdn: nil,
      country_id: "jp")

    # Blank repeater
    create(:repeater, call_sign: nil, keeper: nil)
  end

  after(:context) do
    Repeater.delete_all
  end
end
