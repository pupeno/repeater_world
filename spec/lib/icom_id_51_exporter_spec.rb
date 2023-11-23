require "rails_helper"

RSpec.describe IcomId51Exporter do
  it "should export" do
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
      utc_offset: "0:00",
      source: "ukrepeater.net")
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
      utc_offset: "0:00",
      source: "ukrepeater.net")
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
      utc_offset: "0:00",
      source: "ukrepeater.net")
    create(:repeater,
      name: "Dufton", call_sign: "GB3VE", band: "70cm", channel: "RB04", keeper: "G0TNF",
      operational: false, notes: nil,
      tx_frequency: 433100000, rx_frequency: 434700000,
      fm: false, access_method: "ctcss", ctcss_tone: 77, tone_sql: false,
      dstar: true,
      fusion: false,
      dmr: false, dmr_cc: nil, dmr_con: nil,
      nxdn: nil,
      grid_square: "IO84SQ", latitude: 54.68, longitude: -2.46,
      country_id: "gb", region_1: "England", region_2: "North England", region_3: "CA16", region_4: "Dufton",
      utc_offset: "0:00",
      source: "ukrepeater.net")
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
      source: "ukrepeater.net")
    create(:repeater, call_sign: nil, utc_offset: "12:00")

    exporter = IcomId51Exporter.new(Repeater.all)

    expect(exporter.export).to eq(<<~CSV)
      Group No,Group Name,Name,Sub Name,Repeater Call Sign,Gateway Call Sign,Frequency,Dup,Offset,Mode,TONE,Repeater Tone,RPT1USE,Position,Latitude,Longitude,UTC Offset
      1,United Kingdom,Derby,England,GB7DC,,430.875000,DUP+,7.600000,FM,TONE,71.9Hz,YES,Approximate,52.900000,-1.400000,--:--
      1,United Kingdom,Derby,England,GB7DC  B,GB7DC  G,430.875000,DUP+,7.600000,DV,OFF,88.5Hz,YES,Approximate,52.900000,-1.400000,--:--
      1,United Kingdom,Dufton,England,GB3VE  B,GB3VE  G,433.100000,DUP+,1.600000,DV,OFF,88.5Hz,YES,Approximate,54.680000,-2.460000,0:00
      1,United Kingdom,Herne Bay,No CTCSS,GB7IC C,,145.662500,DUP-,0.600000,FM,OFF,88.5Hz,YES,Approximate,51.360000,1.150000,0:00
      1,United Kingdom,Herne Bay,England,GB7IC  C,GB7IC  G,145.662500,DUP-,0.600000,DV,OFF,88.5Hz,YES,Approximate,51.360000,1.150000,0:00
      1,United Kingdom,Newcastle Emlyn,Wales &,GB3CN,,145.687500,DUP-,0.600000,FM,TONE,94.8Hz,YES,Approximate,51.990000,-4.400000,0:00
      1,United Kingdom,Repeater,WM,,,144.962500,DUP-,0.600000,FM,OFF,88.5Hz,YES,Approximate,51.740000,-3.420000,12:00
      1,United Kingdom,Weymouth,No CTCSS,GB3DR,,145.737500,DUP-,0.600000,FM,OFF,88.5Hz,YES,Approximate,50.550000,-2.440000,0:00
    CSV
  end
end
