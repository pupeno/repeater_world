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

require "rails_helper"

RSpec.describe ChirpExporter do
  include_context "repeaters"

  it "should export" do
    exporter = ChirpExporter.new(Repeater.order(:call_sign, :tx_frequency))

    expect(exporter.export).to eq(<<~CSV)
      Location,Name,Frequency,Duplex,Offset,Tone,rToneFreq,cToneFreq,DtcsCode,DtcsPolarity,RxDtcsCode,CrossMode,Mode,TStep,Skip,Power,Comment,URCALL,RPT1CALL,RPT2CALL,DVCODE
      0,BL4NK,144.370000,-,0.600000,,88.5,88.5,023,NN,023,Tone->Tone,FM,5.00,,50W,Repeater BL4NK BL4NK,,,,
      1,FU11,144.362500,-,0.600000,Tone,67.0,67.0,023,NN,023,Tone->Tone,FM,5.00,,50W,Repeater FU11 FU11,,,,
      2,GB3CN,145.087500,-,0.600000,Tone,94.8,94.8,023,NN,023,Tone->Tone,FM,5.00,,50W,Newcastle Emlyn GB3CN,,,,
      3,GB3DR,145.137500,-,0.600000,,88.5,88.5,023,NN,023,Tone->Tone,FM,5.00,,50W,Weymouth GB3DR,,,,
      4,GB7DC,438.475000,+,7.600000,Tone,71.9,71.9,023,NN,023,Tone->Tone,FM,5.00,,50W,Derby GB7DC,,,,
      5,GB7IC-C,145.062500,-,0.600000,,88.5,88.5,023,NN,023,Tone->Tone,FM,5.00,,50W,Herne Bay GB7IC-C,,,,
    CSV
  end
end