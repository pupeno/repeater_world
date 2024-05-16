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

require "rails_helper"

RSpec.describe IcomId52Exporter do
  include_context "repeaters"

  it "should export" do
    exporter = IcomId52Exporter.new(build(:repeater_search).run)

    expect(exporter.export).to eq(<<~CSV)
      Group No,Group Name,Name,Sub Name,Repeater Call Sign,Gateway Call Sign,Frequency,Dup,Offset,Mode,TONE,Repeater Tone,RPT1USE,Position,Latitude,Longitude,UTC Offset
      1,United Kingdom,Derby,Midlands,GB7DC,,430.875000,DUP+,7.600000,FM,TONE,71.9Hz,YES,Approximate,52.900000,-1.400000,--:--
      1,United Kingdom,Derby,Midlands,GB7DC  B,GB7DC  G,430.875000,DUP+,7.600000,DV,,,YES,Approximate,52.900000,-1.400000,--:--
      1,United Kingdom,Herne Bay,Missing Tone,GB7IC C,,145.662500,DUP-,0.600000,FM,OFF,88.5Hz,YES,Approximate,51.360000,1.150000,0:00
      1,United Kingdom,Herne Bay,South Ea,GB7IC  C,GB7IC  G,145.662500,DUP-,0.600000,DV,,,YES,Approximate,51.360000,1.150000,0:00
      1,Japan,Made up,,JP0AA  A,JP0AA  G,439.420000,DUP-,9.000000,DV,,,YES,Approximate,,,--:--
      1,United Kingdom,Marlborough,South We,GB7AE  B,GB7AE  G,439.425000,DUP-,9.000000,DV,,,YES,Approximate,51.420000,-1.760000,0:00
      1,United Kingdom,Newcastle Emlyn,Wales &,GB3CN,,145.687500,DUP-,0.600000,FM,TONE,94.8Hz,YES,Approximate,51.990000,-4.400000,0:00
      1,United Kingdom,Repeater BL4NK,Missing Tone,BL4NK,,144.970000,DUP-,0.600000,FM,OFF,88.5Hz,YES,Approximate,,,--:--
      1,United Kingdom,Repeater FU11,city,FU11,,144.962500,DUP-,0.600000,FM,TONE,67.0Hz,YES,Approximate,51.740000,-3.420000,05:00
      1,United Kingdom,Repeater FU11,city,FU11   C,FU11   G,144.962500,DUP-,0.600000,DV,,,YES,Approximate,51.740000,-3.420000,05:00
      1,United Kingdom,Weymouth,South We,GB3DR,,145.737500,DUP-,0.600000,FM,OFF,88.5Hz,YES,Approximate,50.550000,-2.440000,0:00
    CSV
  end
end
