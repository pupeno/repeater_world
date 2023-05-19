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

RSpec.describe CsvExporter do
  include_context "repeaters"

  it "should export" do
    exporter = CsvExporter.new(Repeater.order(:call_sign, :tx_frequency).all)

    expect(exporter.export).to eq(<<~CSV)
      Name,Call Sign,Band,Channel,Keeper,Operational,Notes,Tx Frequency,Rx Frequency,FM,Access Method,CTCSS Tone,Tone SQL,D-Star,Fusion,DMR,DMR Color Code,DMR Network,NXDN,Latitude,Longitude,Grid Square,Address,Locality,Region,Post Code,Country,UTC Offset,Source,Redistribution Limitations
      Hawick,GB3AI,2m,RV59,GM8SJP,false,,145737500.0,145137500.0,true,ctcss,103.5,,true,true,true,3,DV Scotland Phoenix,,55.4,-2.7,IO85PK,address,Hawick,Scotland,TD9,gb,0:00,ukrepeater.net,
      Amersham,GB3AM,6m,R50-13,M0ZPU,true,,50840000.0,51340000.0,true,ctcss,77.0,false,false,false,false,,,,51.65,-0.62,IO91QP,address,Amersham,"South West, England",HP7,gb,0:00,ukrepeater.net,
      Cleobury North,GB3BX,2m,RV54,G4VZO,true,Reduced output.,145675000.0,145075000.0,false,,,,false,false,true,13,SALOP DMR,,52.5,-2.6,IO82QL,address,Cleobury North,Wales & Marches,SY7,gb,0:00,ukrepeater.net,
      Newcastle Emlyn,GB3CN,2m,RV55,GW6JSO,true,,145687500.0,145087500.0,true,ctcss,94.8,false,false,false,false,,,,51.99,-4.4,IO71TX,address,Newcastle Emlyn,Wales & Marches,SA44,gb,0:00,ukrepeater.net,https://repeater.world/ukrepeater-net
      Weymouth,GB3DR,2m,RV59,G3VPF,true,,145737500.0,145137500.0,true,,,,false,true,false,,,,50.55,-2.44,IO80SN,address,Weymouth,"South West, England",DT5,gb,0:00,ukrepeater.net,
      Perth,GB3SF,2m,RV50,GM3NFO,true,,145625000.0,145025000.0,false,,,,false,true,false,,,,56.5,-3.4,IO86HK,address,Perth,Scotland,PH2,gb,0:00,ukrepeater.net,
      Marlborough,GB7AE,70cm,DVU34,M1CJE,true,,439425000.0,430425000.0,false,,,,true,false,false,,,,51.42,-1.76,IO91CJ,address,Marlborough,"South West, England",SN8,gb,0:00,ukrepeater.net,
      Derby,GB7DC,70cm,RU70,G7NPW,true,Reduced output.,430875000.0,438475000.0,true,ctcss,71.9,false,true,true,true,1,BRANDMEISTER,true,52.9,-1.4,IO92GW,address,Derby,"Midlands, England",DE21,gb,,ukrepeater.net,
      Herne Bay,GB7IC-C,2m,RV53,G4TKR,true,,145662500.0,145062500.0,true,,,,true,false,false,,,,51.36,1.15,JO01NI,address,Herne Bay,"South East, England",CT6,gb,0:00,ukrepeater.net,
      Made up,JP0AA,70cm,,JP0ZZ,true,,439420000.0,430420000.0,false,,,,true,false,false,,,,51.74,-3.42,IO81HR,address,city,region,PC,jp,,,
      Made up,JP0AA,23cm,,JP0ZZ,true,,1297900000.0,1297900000.0,false,,,,true,false,false,,,,51.74,-3.42,IO81HR,address,city,region,PC,jp,,,
      Repeater,,2m,,,true,,144962500.0,144362500.0,true,tone_burst,,,,,,,,,51.74,-3.42,IO81HR,address,city,region,PC,gb,,,
    CSV
  end
end
