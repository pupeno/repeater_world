require "rails_helper"

RSpec.describe IcomId52Exporter do
  it "should export" do
    _repeaters = [
      create(:repeater,
             name: "Weymouth", call_sign: "GB3DR", band: "2m", channel: "RV59", keeper: "G3VPF",
             operational: true, notes: nil,
             tx_frequency: 145737500, rx_frequency: 145137500,
             fm: true, access_method: nil, ctcss_tone: nil, tone_sql: nil,
             dstar: false,
             fusion: true,
             dmr: false, dmr_cc: nil, dmr_con: nil,
             nxdn: nil,
             grid_square: "IO80SN", latitude: 50.55, longitude: -2.44, country_id: "gb", region_1: "England", region_2: "South West", region_3: "DT5", region_4: "Weymouth", source: "ukrepeater.net"),
      create(:repeater,
             name: "Dufton", call_sign: "GB3VE", band: "70cm", channel: "RB04", keeper: "G0TNF",
             operational: false, notes: nil,
             tx_frequency: 433100000, rx_frequency: 434700000,
             fm: false, access_method: "ctcss", ctcss_tone: 77, tone_sql: false,
             dstar: true,
             fusion: false,
             dmr: false, dmr_cc: nil, dmr_con: nil,
             nxdn: nil,
             grid_square: "IO84SQ", latitude: 54.68, longitude: -2.46, country_id: "gb", region_1: "England", region_2: "North England", region_3: "CA16", region_4: "Dufton", source: "ukrepeater.net"),
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
             source: "ukrepeater.net")]

    exporter = IcomId52Exporter.new(Repeater.all)

    expect(exporter.export).to eq(<<~CSV)
        Group No,Group Name,Name,Sub Name,Repeater Call Sign,Gateway Call Sign,Frequency,Dup,Offset,Mode,TONE,Repeater Tone,RPT1USE,Position,Latitude,Longitude,UTC Offset
        1,United Kingdom,Derby,England,GB7DC,,430.875000,DUP+,7.600000,FM,TONE,71.9Hz,YES,Approximate,52.900000,-1.400000,--:--
        1,United Kingdom,Dufton,England,GB3VE  B,GB3VE  G,433.100000,DUP+,1.600000,DV,,,YES,Approximate,54.680000,-2.460000,--:--
        1,United Kingdom,Weymouth,No CTCSS,GB3DR,,145.737500,DUP-,0.600000,FM,OFF,88.5Hz,YES,Approximate,50.550000,-2.440000,--:--
      CSV
  end
end
