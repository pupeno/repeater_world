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

RSpec.describe CsvExporter do
  include_context "repeaters"

  it "should export" do
    exporter = CsvExporter.new(Repeater.order(:call_sign, :tx_frequency))

    expect(exporter.export).to eq(<<~CSV)
      Name,Call Sign,Web Site,Keeper,Band,Operational,Tx Frequency,Rx Frequency,FM,Tone Burst,CTCSS Tone,Tone Squelch,D-Star,Fusion,DMR,DMR Color Code,DMR Network,NXDN,P25,Tetra,Latitude,Longitude,Grid Square,Address,Locality,Region,Post Code,Country,Tx Power,Tx Antenna,Tx Antenna Polarization,Rx Antenna,Rx Antenna Polarization,Altitude Asl,Altitude Agl,Bearing,UTC Offset,Channel,Notes,Source,Redistribution Limitations
      Repeater BL4NK,BL4NK,,,2m,true,144962500,144362500,true,,,,,,,,,,,,51.74,-3.42,IO81HR,address,city,region,PC,gb,,,,,,,,,,,,,
      Hawick,GB3AI,,GM8SJP,2m,false,145737500,145137500,true,,103.5,,true,true,true,3,DV Scotland Phoenix,,,,55.4,-2.7,IO85PK,address,Hawick,Scotland,TD9,gb,,,,,,,,,0:00,RV59,,ukrepeater.net,
      Amersham,GB3AM,,M0ZPU,6m,true,50840000,51340000,true,,77.0,false,false,false,false,,,,,,51.65,-0.62,IO91QP,address,Amersham,"South West, England",HP7,gb,,,,,,,,,0:00,R50-13,,ukrepeater.net,
      Cleobury North,GB3BX,,G4VZO,2m,true,145675000,145075000,false,,,,false,false,true,13,SALOP DMR,,,,52.5,-2.6,IO82QL,address,Cleobury North,Wales & Marches,SY7,gb,,,,,,,,,0:00,RV54,Reduced output.,ukrepeater.net,
      Newcastle Emlyn,GB3CN,,GW6JSO,2m,true,145687500,145087500,true,,94.8,false,false,false,false,,,,,,51.99,-4.4,IO71TX,address,Newcastle Emlyn,Wales & Marches,SA44,gb,,,,,,,,,0:00,RV55,,ukrepeater.net,https://repeater.world/ukrepeater-net
      Weymouth,GB3DR,,G3VPF,2m,true,145737500,145137500,true,true,,,false,true,false,,,,,,50.55,-2.44,IO80SN,address,Weymouth,"South West, England",DT5,gb,,,,,,,,,0:00,RV59,,ukrepeater.net,
      Perth,GB3SF,,GM3NFO,2m,true,145625000,145025000,false,,,,false,true,false,,,,,,56.5,-3.4,IO86HK,address,Perth,Scotland,PH2,gb,,,,,,,,,0:00,RV50,,ukrepeater.net,
      Marlborough,GB7AE,,M1CJE,70cm,true,439425000,430425000,false,,,,true,false,false,,,,,,51.42,-1.76,IO91CJ,address,Marlborough,"South West, England",SN8,gb,,,,,,,,,0:00,DVU34,,ukrepeater.net,
      Derby,GB7DC,,G7NPW,70cm,true,430875000,438475000,true,,71.9,false,true,true,true,1,BRANDMEISTER,true,,,52.9,-1.4,IO92GW,address,Derby,"Midlands, England",DE21,gb,,,,,,,,,,RU70,Reduced output.,ukrepeater.net,
      Herne Bay,GB7IC-C,,G4TKR,2m,true,145662500,145062500,true,,,,true,false,false,,,,,,51.36,1.15,JO01NI,address,Herne Bay,"South East, England",CT6,gb,,,,,,,,,0:00,RV53,,ukrepeater.net,
      Made up,JP0AA,,JP0ZZ,70cm,true,439420000,430420000,false,,,,true,false,false,,,,,,51.74,-3.42,IO81HR,address,city,region,PC,jp,,,,,,,,,,,,,
      Made up,JP0AA,,JP0ZZ,23cm,true,1297900000,1297900000,false,,,,true,false,false,,,,,,51.74,-3.42,IO81HR,address,city,region,PC,jp,,,,,,,,,,,,,
    CSV
  end
end
