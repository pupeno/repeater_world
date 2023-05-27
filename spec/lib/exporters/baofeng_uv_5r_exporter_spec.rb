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

RSpec.describe BaofengUv5rExporter do
  include_context "repeaters"

  it "should export" do
    exporter = BaofengUv5rExporter.new(Repeater.order(:call_sign, :tx_frequency))

    expect(exporter.export).to eq(<<~CSV)
      Location,Name,Frequency,Duplex,Offset,Tone,rToneFreq,cToneFreq,DtcsCode,DtcsPolarity,Mode,TStep,Skip,Comment,URCALL,RPT1CALL,RPT2CALL,DVCODE
      0,FU11,144.362500,-,0.600000,TONE,67.0,67.0,023,NN,FM,5,,Repeater FU11 FU11,,,,
      1,GB3CN,145.087500,-,0.600000,TONE,94.8,94.8,023,NN,FM,5,,Newcastle Emlyn GB3CN,,,,
      2,GB3DR,145.137500,-,0.600000,,88.5,88.5,023,NN,FM,5,,Weymouth GB3DR,,,,
      3,GB7DC,438.475000,+,7.600000,TONE,71.9,71.9,023,NN,FM,5,,Derby GB7DC,,,,
      4,GB7IC-C,145.062500,-,0.600000,,88.5,88.5,023,NN,FM,5,,Herne Bay GB7IC-C,,,,
    CSV
  end

  it "should not export more than 127 repeaters" do
    128.times { create(:repeater, :full) }

    exporter = BaofengUv5rExporter.new(Repeater.order(:call_sign, :tx_frequency))

    expect(exporter.export.count("\n")).to eq(129)
  end
end
