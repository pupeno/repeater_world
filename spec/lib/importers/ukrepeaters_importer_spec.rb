# Copyright 2023, Pablo Fernandez
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Foobar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with Foobar. If not, see
# <https://www.gnu.org/licenses/>.

require "rails_helper"

RSpec.describe UkrepeatersImporter do
  it "should import" do
    files = {"https://ukrepeater.net/csvcreate3.php" => "repeaterlist3.csv",
             "https://ukrepeater.net/csvcreate_dv.php" => "repeaterlist_dv.csv",
             "https://ukrepeater.net/csvcreate_all.php" => "repeaterlist_all.csv",
             "https://ukrepeater.net/repeaterlist-alt.php" => "repeaterlist_alt2.csv",
             "https://ukrepeater.net/csvcreatewithstatus.php" => "repeaterlist_status.csv"}

    files.each do |url, local_file|
      file = double("file")
      local_file = Rails.root.join("spec", "factories", "ukrepeaters_importer_data", local_file)
      expect(file).to receive(:open).and_return(File.new(local_file))
      expect(URI).to receive(:parse).with(url).and_return(file)
    end

    Dir.mktmpdir("ukrepeaters") do |dir|
      expect do
        UkrepeatersImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(905)

      repeater = Repeater.find_by(call_sign: "GB7DC")
      expect(repeater.name).to eq("Derby")
      expect(repeater.band).to eq(Repeater::BAND_70CM)
      expect(repeater.channel).to eq("RU70")
      expect(repeater.keeper).to eq("G7NPW")
      expect(repeater.operational).to eq(true)
      expect(repeater.notes).to eq("Reduced output.")
      expect(repeater.tx_frequency).to eq(430875000)
      expect(repeater.rx_frequency).to eq(438475000)
      expect(repeater.fm).to eq(true)
      expect(repeater.access_method).to eq(Repeater::CTCSS)
      expect(repeater.ctcss_tone).to eq(71.9)
      expect(repeater.tone_sql).to eq(false)
      expect(repeater.dstar).to eq(true)
      expect(repeater.fusion).to eq(true)
      expect(repeater.dmr).to eq(true)
      expect(repeater.dmr_cc).to eq(1)
      expect(repeater.dmr_con).to eq("BRANDMEISTER")
      expect(repeater.nxdn).to eq(true)
      expect(repeater.grid_square).to eq("IO92GW")
      expect(repeater.latitude).to eq(52.9)
      expect(repeater.longitude).to eq(-1.4)
      expect(repeater.country_id).to eq("gb")
      expect(repeater.region_1).to eq("England")
      expect(repeater.region_2).to eq("Midlands")
      expect(repeater.region_3).to eq("DE21")
      expect(repeater.region_4).to eq("Derby")
      expect(repeater.utc_offset).to eq("0:00")

      # The second time we call it, it shouldn't re-download any files, nor create new
      # repeaters
      expect do
        UkrepeatersImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(0)

      # Some repeaters change, some get disconnected from the source, other's don't.
      repeater = Repeater.find_by(call_sign: "GB3HI")
      repeater.band = Repeater::BAND_23CM
      repeater.source = nil
      repeater.redistribution_limitations = nil
      repeater.save!
      repeater = Repeater.find_by(call_sign: "GB3NL")
      repeater.band = Repeater::BAND_23CM
      repeater.save!

      # The third time we call it, it shouldn't re-download any files, nor create new
      # repeaters, but some get updated and some don't.
      expect do
        UkrepeatersImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(0)
      repeater = Repeater.find_by(call_sign: "GB3HI") # This one didn't change.
      expect(repeater.band).to eq(Repeater::BAND_23CM)
      repeater = Repeater.find_by(call_sign: "GB3NL") # This one did
      expect(repeater.band).to eq(Repeater::BAND_2M)
    end
  end
end
