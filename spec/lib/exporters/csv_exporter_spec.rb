# Copyright 2023-2024, Pablo Fernandez
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
    @non_exportable_columns = ["Id", "Coordinates", "Input coordinates", "Created at", "Updated at", "Geocoded at",
      "Geocoded by", "Slug"]

    exporter = CsvExporter.new(build(:repeater_search).run)

    exported_csv = exporter.export

    headers = CSV.parse(exported_csv).first
    Repeater.columns.map { |c| Repeater.human_attribute_name(c.name) }.each do |column_name|
      if column_name.in? @non_exportable_columns
        expect(headers).not_to include(column_name)
      else
        expect(headers).to include(column_name)
      end
    end

    expect(exported_csv).to eq(<<~CSV)
      Name,Call sign,Web site,Keeper,Band,Cross band,Operational,Transmit frequency,Receive frequency,FM,Tone burst,CTCSS tone,DCS code,Tone squelch,M17,M17 channel access number,M17 reflector name,D-Star,D-Star port,Fusion,Wires-X Node Id,DMR,DMR color code,DMR network,NXDN,P25,Tetra,EchoLink,EchoLink node number,Bandwidth,Address,City or town,"Region, state, or province",Post code or ZIP,Country,Grid square,Latitude,Longitude,Transmit power,Transmit antenna,Transmit antenna polarization,Receive antenna,Receive antenna polarization,Altitude above sea level,Altitude above ground level,Bearing,Irlp,Irlp node number,UTC offset,Channel,Notes,Source,Redistribution limitations,External id
      Amersham,GB3AM,,M0ZPU,6m,,true,50840000,51340000,true,false,77.0,,false,false,,,false,,false,,false,,,false,false,false,,,,,Amersham,"South West, England",HP7,gb,IO91QP,51.65,-0.62,,,,,,,,,,,0:00,R50-13,,ukrepeater.net,,
      Cleobury North,GB3BX,,G4VZO,2m,,true,145675000,145075000,false,false,,,false,false,,,false,,false,,true,13,SALOP DMR,false,false,false,,,,,Cleobury North,Wales & Marches,SY7,gb,IO82QL,52.5,-2.6,,,,,,,,,,,0:00,RV54,,ukrepeater.net,,
      Derby,GB7DC,,G7NPW,70cm,,,430875000,438475000,true,false,71.9,,false,false,,,true,,true,,true,1,BRANDMEISTER,true,false,false,,,,,Derby,"Midlands, England",DE21,gb,IO92GW,52.9,-1.4,,,,,,,,,,,,RU70,Reduced output.,ukrepeater.net,,
      Hawick,GB3AI,,GM8SJP,2m,,false,145737500,145137500,true,false,103.5,,false,false,,,true,,true,,true,3,DV Scotland Phoenix,false,false,false,,,,,Hawick,Scotland,TD9,gb,IO85PK,55.4,-2.7,,,,,,,,,,,0:00,RV59,,ukrepeater.net,,
      Herne Bay,GB7IC-C,,G4TKR,2m,,true,145662500,145062500,true,false,,,false,false,,,true,,false,,false,,,false,false,false,,,,,Herne Bay,"South East, England",CT6,gb,JO01NI,51.36,1.15,,,,,,,,,,,0:00,RV53,,ukrepeater.net,,
      Made up,JP0AA,,JP0ZZ,70cm,,true,439420000,430420000,false,false,,,false,false,,,true,,false,,false,,,false,false,false,,,,,,,,jp,FN20xr,40.7143528,-74.0059731,,,,,,,,,,,,,,,,
      Made up,JP0AA,,JP0ZZ,23cm,,true,1297900000,1297900000,false,false,,,false,false,,,true,,false,,false,,,false,false,false,,,,,,,,jp,FN20xr,40.7143528,-74.0059731,,,,,,,,,,,,,,,,
      Marlborough,GB7AE,,M1CJE,70cm,,true,439425000,430425000,false,false,,,false,false,,,true,,false,,false,,,false,false,false,,,,,Marlborough,"South West, England",SN8,gb,IO91CJ,51.42,-1.76,,,,,,,,,,,0:00,DVU34,,ukrepeater.net,,
      Newcastle Emlyn,GB3CN,,GW6JSO,2m,,true,145687500,145087500,true,false,94.8,,false,false,,,false,,false,,false,,,false,false,false,,,,,Newcastle Emlyn,Wales & Marches,SA44,gb,IO71TX,51.99,-4.4,,,,,,,,,,,0:00,RV55,,ukrepeater.net,https://repeater.world/ukrepeater-net,
      Perth,GB3SF,,GM3NFO,2m,,true,145625000,145025000,false,false,,,false,false,,,false,,true,,false,,,false,false,false,,,,,Perth,Scotland,PH2,gb,IO86HK,56.5,-3.4,,,,,,,,,,,0:00,RV50,,ukrepeater.net,,
      Repeater BL4NK,BL4NK,,,2m,,,144962500,144362500,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
      Repeater BL4NK,BL4NK,,,2m,,,144970000,144370000,true,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
      Repeater FU11,FU11,https://website,K3EPR,2m,,true,144962500,144362500,true,true,67.0,23,true,true,5,m17 reflector,true,C,true,,true,1,Brandmeister,true,true,true,,,25000,address,city,region,PC,gb,IO81HR,51.74,-3.42,50,tx_antenna,V,rx_antenna,V,200,150,bearing,,,05:00,channel,Notes,source,redistribution_limitations,external id
      Weymouth,GB3DR,,G3VPF,2m,,,145737500,145137500,true,true,,,false,false,,,false,,true,,false,,,false,false,false,,,,,Weymouth,"South West, England",DT5,gb,IO80SN,50.55,-2.44,,,,,,,,,,,0:00,RV59,,ukrepeater.net,,
    CSV
  end
end
