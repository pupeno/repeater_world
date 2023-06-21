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

RSpec.describe UkrepeatersImporter do
  before do
    Repeater.delete_all
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
  end

  it "should import" do
    Dir.mktmpdir("ukrepeatersimporter") do |dir|
      expect do
        UkrepeatersImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(914)

      # Grab some repeaters and verify they were imported correctly.
      repeater = Repeater.find_by(call_sign: "GB7DC")
      expect(repeater.name).to eq("Derby")
      expect(repeater.band).to eq(Repeater::BAND_70CM)
      expect(repeater.channel).to eq("RU70")
      expect(repeater.keeper).to eq("G7NPW")
      expect(repeater.operational).to eq(true)
      expect(repeater.notes).to eq(nil)
      expect(repeater.tx_frequency).to eq(430875000)
      expect(repeater.rx_frequency).to eq(438475000)
      expect(repeater.fm).to eq(true)
      expect(repeater.fm_tone_burst).to eq(nil)
      expect(repeater.fm_ctcss_tone).to eq(71.9)
      expect(repeater.fm_tone_squelch).to eq(nil)
      expect(repeater.dstar).to eq(true)
      expect(repeater.fusion).to eq(true)
      expect(repeater.dmr).to eq(true)
      expect(repeater.dmr_color_code).to eq(1)
      expect(repeater.dmr_network).to eq("BRANDMEISTER")
      expect(repeater.nxdn).to eq(true)
      expect(repeater.grid_square).to eq("IO92GW")
      expect(repeater.latitude).to eq(52.9)
      expect(repeater.longitude).to eq(-1.4)
      expect(repeater.country_id).to eq("gb")
      expect(repeater.locality).to eq("Derby")
      expect(repeater.post_code).to eq("DE21")
      expect(repeater.region).to eq("Central England")
      expect(repeater.utc_offset).to eq("0:00")
    end
  end

  it "should not import anything new on a second pass" do
    Dir.mktmpdir("ukrepeatersimporter") do |dir|
      UkrepeatersImporter.new(working_directory: dir).import

      # The second time we call it, it shouldn't re-download any files, nor create new repeaters
      expect do
        UkrepeatersImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(0)
    end
  end

  it "should respect the source values during import" do
    Dir.mktmpdir("ukrepeatersimporter") do |dir|
      UkrepeatersImporter.new(working_directory: dir).import

      # This repeater simulates a previously imported repeater that is no longer in the source files, so we should
      # delete it to avoid stale data.
      will_delete = "GB7DC"
      create(:repeater, :full, call_sign: will_delete, tx_frequency: 145_000_001, source: UkrepeatersImporter::SOURCE)

      # This repeater represents one where the upstream data changed and should be updated by the importer.
      will_update = "GB3NL"
      repeater = Repeater.find_by(call_sign: will_update)
      repeater.rx_frequency = 1_000_000
      repeater.save!

      # This repeater represents one that got taken over by the owner becoming a Repeater World user, that means the
      # source is now nil. This should never again be overwritten by the importer.
      wont_update = "GB3HI"
      repeater = Repeater.find_by(call_sign: wont_update)
      repeater.rx_frequency = 1_000_000
      repeater.source = nil
      repeater.save!

      # Run the import and verify we removed one repeater but otherwise made no changes.
      expect do
        UkrepeatersImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(-1)
        .and change { Repeater.where(call_sign: will_delete, tx_frequency: 145_000_001).count }.by(-1)

      # This one got deleted
      repeater = Repeater.find_by(call_sign: will_delete, tx_frequency: 145_000_001)
      expect(repeater).to be(nil)

      # This got updated.
      repeater = Repeater.find_by(call_sign: will_update)
      expect(repeater.rx_frequency).to eq(145_175_000)

      # This one didn't change.
      repeater = Repeater.find_by(call_sign: wont_update)
      expect(repeater.rx_frequency).to eq(1_000_000)
    end
  end
end
