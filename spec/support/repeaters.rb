RSpec.shared_context "repeaters" do
  before(:context) do
    Repeater.delete_all

    # FM repeater with CTCSS
    create(:repeater,
           name: "Newcastle Emlyn", call_sign: "GB3CN", band: "2m", channel: "RV55", keeper: "GW6JSO",
           operational: true, notes: nil,
           tx_frequency: 145687500, rx_frequency: 145087500,
           fm: true, access_method: "ctcss", ctcss_tone: 94.8, tone_sql: false,
           dstar: false,
           fusion: false,
           dmr: false, dmr_cc: nil, dmr_con: nil,
           nxdn: nil,
           grid_square: "IO71TX", latitude: 51.99, longitude: -4.4,
           country_id: "gb", region_1: "Wales & Marches", region_2: "Wales & Marches", region_3: "SA44", region_4: "Newcastle Emlyn",
           utc_offset: "0:00", source: "ukrepeater.net")

    # FM repeater without CTCSS
    create(:repeater,
           name: "Weymouth", call_sign: "GB3DR", band: "2m", channel: "RV59", keeper: "G3VPF",
           operational: true, notes: nil,
           tx_frequency: 145737500, rx_frequency: 145137500,
           fm: true, access_method: nil, ctcss_tone: nil, tone_sql: nil,
           dstar: false,
           fusion: true,
           dmr: false, dmr_cc: nil, dmr_con: nil,
           nxdn: nil,
           grid_square: "IO80SN", latitude: 50.55, longitude: -2.44,
           country_id: "gb", region_1: "England", region_2: "South West", region_3: "DT5", region_4: "Weymouth",
           utc_offset: "0:00", source: "ukrepeater.net")

    # FM and D-Star repeater.
    create(:repeater,
           name: "Herne Bay", call_sign: "GB7IC-C", band: "2m", channel: "RV53", keeper: "G4TKR",
           operational: true, notes: nil,
           tx_frequency: 145662500, rx_frequency: 145062500,
           fm: true, access_method: nil, ctcss_tone: nil, tone_sql: nil,
           dstar: true,
           fusion: false,
           dmr: false, dmr_cc: nil, dmr_con: nil,
           nxdn: nil,
           grid_square: "JO01NI", latitude: 51.36, longitude: 1.15,
           country_id: "gb", region_1: "England", region_2: "South East", region_3: "CT6", region_4: "Herne Bay",
           utc_offset: "0:00", source: "ukrepeater.net")

    # D-Star repeater only.
    create(:repeater,
           name: "Marlborough", call_sign: "GB7AE", band: "70cm", channel: "DVU34", keeper: "M1CJE",
           operational: true, notes: nil,
           tx_frequency: 439425000,
           rx_frequency: 430425000,
           fm: false, access_method: nil, ctcss_tone: nil, tone_sql: nil,
           dstar: true,
           fusion: false,
           dmr: false, dmr_cc: nil, dmr_con: nil, nxdn: nil,
           grid_square: "IO91CJ", latitude: 51.42, longitude: -1.76,
           country_id: "gb", region_1: "England", region_2: "South West", region_3: "SN8", region_4: "Marlborough",
           utc_offset: "0:00", source: "ukrepeater.net")

    # FM and Fusion repeater.
    create(:repeater,
           name: "Derby", call_sign: "GB7DC", band: "70cm", channel: "RU70", keeper: "G7NPW",
           operational: true, notes: "Reduced output.",
           tx_frequency: 430875000,
           rx_frequency: 438475000,
           fm: true, access_method: "ctcss", ctcss_tone: 71.9, tone_sql: false,
           dstar: true,
           fusion: true,
           dmr: true, dmr_cc: 1, dmr_con: "BRANDMEISTER",
           nxdn: true,
           grid_square: "IO92GW", latitude: 52.9, longitude: -1.4, country_id: "gb", region_1: "England", region_2: "Midlands", region_3: "DE21", region_4: "Derby",
           utc_offset: nil, source: "ukrepeater.net")

    # DMR and nxdn repeater.
    create(:repeater,
           name: "Cleobury North", call_sign: "GB3BX", band: "2m", channel: "RV54", keeper: "G4VZO",
           operational: true, notes: "Reduced output.",
           tx_frequency: 145675000,
           rx_frequency: 145075000,
           fm: false, access_method: nil, ctcss_tone: nil, tone_sql: nil,
           dstar: false,
           fusion: false,
           dmr: true, dmr_cc: 13, dmr_con: "SALOP DMR",
           nxdn: nil,
           grid_square: "IO82QL", latitude: 52.5, longitude: -2.6, country_id: "gb", region_1: "Wales & Marches", region_2: "Wales & Marches", region_3: "SY7", region_4: "Cleobury North",
           utc_offset: "0:00", source: "ukrepeater.net")

    # Non-2m-70cm repeater.
    create(:repeater,
           name: "Amersham", call_sign: "GB3AM", band: "6m", channel: "R50-13", keeper: "M0ZPU",
           operational: true, notes: nil,
           tx_frequency: 50840000,
           rx_frequency: 51340000,
           fm: true, access_method: "ctcss", ctcss_tone: 77, tone_sql: false,
           dstar: false,
           fusion: false,
           dmr: false, dmr_cc: nil, dmr_con: nil,
           nxdn: nil,
           grid_square: "IO91QP", latitude: 51.65, longitude: -0.62, country_id: "gb", region_1: "England", region_2: "South West", region_3: "HP7", region_4: "Amersham",
           utc_offset: "0:00", source: "ukrepeater.net")

    # Non operational repeater on fm, dstar, fusion and dmr.
    create(:repeater,
           name: "Hawick", call_sign: "GB3AI", band: "2m", channel: "RV59", keeper: "GM8SJP",
           operational: false, notes: nil,
           tx_frequency: 145737500, rx_frequency: 145137500,
           fm: true, access_method: "ctcss", ctcss_tone: 0.1035e3, tone_sql: nil,
           dstar: true,
           fusion: true,
           dmr: true, dmr_cc: 3, dmr_con: "DV Scotland Phoenix",
           nxdn: nil,
           grid_square: "IO85PK", latitude: 55.4, longitude: -2.7,
           country_id: "gb", region_1: "Scotland", region_2: "Scotland", region_3: "TD9", region_4: "Hawick",
           utc_offset: "0:00", source: "ukrepeater.net")

    # Blank repeater
    create(:repeater, call_sign: nil)
  end

  after(:context) do
    Repeater.delete_all
  end
end
