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

RSpec.describe NerepeatersImporter do
  before do
    Repeater.delete_all
    files = {"http://www.nerepeaters.com/NERepeaters.php" => "nerepeaters.csv"}
    files.each do |url, local_file|
      file = double("file")
      local_file = Rails.root.join("spec", "factories", "nerepeaters_importer_data", local_file)
      expect(file).to receive(:open).and_return(File.new(local_file))
      expect(URI).to receive(:parse).with(url).and_return(file)
    end
  end

  it "should import" do
    Dir.mktmpdir("NerepeatersImporter") do |dir|
      expect do
        NerepeatersImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(952)

      # Grab one repeater and verify it was imported correctly.
      repeater = Repeater.find_sole_by(call_sign: "WA1DGW")
      expect(repeater.name).to eq("Fall River WA1DGW")
      expect(repeater.band).to eq(Repeater::BAND_2M)
      expect(repeater.tx_frequency).to eq(145_150_000)
      expect(repeater.rx_frequency).to eq(144_550_000)

      # Check a case where we get multiple repeaters with the same call sign.
      expect(Repeater.where(call_sign: "AA1HD").count).to eq(4)
    end
  end

  it "should not import anything new on a second pass" do
    Dir.mktmpdir("NerepeatersImporter") do |dir|
      NerepeatersImporter.new(working_directory: dir).import

      # The second time we call it, it shouldn't re-download any files, nor create new repeaters
      expect do
        NerepeatersImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(0)
    end
  end

  it "should respect the source values during import" do
    Dir.mktmpdir("NerepeatersImporter") do |dir|
      NerepeatersImporter.new(working_directory: dir).import

      # This repeater simulates a previously imported repeater that is no longer in the source files, so we should
      # delete it to avoid stale data.
      will_delete = "N1PAH"
      create(:repeater, :full, call_sign: will_delete, tx_frequency: 145_000_001, source: NerepeatersImporter::SOURCE)

      # This repeater represents one where the upstream data changed and should be updated by the importer.
      will_update = "AA1TT"
      repeater = Repeater.find_by(call_sign: will_update)
      repeater.rx_frequency = 1_000_000
      repeater.save!

      # This repeater represents one that got taken over by the owner becoming a Repeater World user, that means the
      # source is now nil. This should never again be overwritten by the importer.
      wont_update = "N1MYY"
      repeater = Repeater.find_by(call_sign: wont_update)
      repeater.rx_frequency = 1_000_000
      repeater.source = nil
      repeater.save!

      # Run the import and verify we removed one repeater but otherwise made no changes.
      expect do
        NerepeatersImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(-1)
        .and change { Repeater.where(call_sign: will_delete, tx_frequency: 145_000_001).count }.by(-1)

      # This one got deleted
      repeater = Repeater.find_by(call_sign: will_delete, tx_frequency: 145_000_001)
      expect(repeater).to be(nil)

      # This got updated.
      repeater = Repeater.find_by(call_sign: will_update)
      expect(repeater.rx_frequency).to eq(223_440_000)

      # This one didn't change.
      repeater = Repeater.find_by(call_sign: wont_update)
      expect(repeater.rx_frequency).to eq(1_000_000)
    end
  end
end
