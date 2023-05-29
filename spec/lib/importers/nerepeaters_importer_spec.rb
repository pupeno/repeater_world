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

RSpec.describe NerepeatersImporter do
  it "should import" do
    files = {"http://www.nerepeaters.com/NERepeaters.php" => "nerepeaters.csv"}

    files.each do |url, local_file|
      file = double("file")
      local_file = Rails.root.join("spec", "factories", "nerepeaters_importer_data", local_file)
      expect(file).to receive(:open).and_return(File.new(local_file))
      expect(URI).to receive(:parse).with(url).and_return(file)
    end

    Dir.mktmpdir("NerepeatersImporter") do |dir|
      expect do
        NerepeatersImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(952)

      expect(Repeater.where(call_sign: "W1WNS").count).to eq(3)

      repeater = Repeater.find_sole_by(call_sign: "WA1DGW")
      expect(repeater.name).to eq("Fall River WA1DGW")
      expect(repeater.band).to eq(Repeater::BAND_2M)
      expect(repeater.tx_frequency).to eq(145_150_000)
      expect(repeater.rx_frequency).to eq(144_550_000)

      # The second time we call it, it shouldn't re-download any files, nor create new
      # repeaters
      expect do
        NerepeatersImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(0)

      # Some repeaters change, some get disconnected from the source, other's don't.
      repeater = Repeater.find_by(call_sign: "N1MYY")
      repeater.band = Repeater::BAND_23CM
      repeater.source = nil
      repeater.redistribution_limitations = nil
      repeater.save!
      repeater = Repeater.find_by(call_sign: "AA1TT")
      repeater.band = Repeater::BAND_23CM
      repeater.save!
      create(:repeater, :full, call_sign: "N1PAH", tx_frequency: 145_000_001, source: NerepeatersImporter::SOURCE)

      # The third time we call it, it shouldn't re-download any files, nor create new
      # repeaters, but some get updated, some don't, and some get deleted.
      expect(Repeater.where(call_sign: "N1PAH").count).to eq(6)
      expect do
        NerepeatersImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(-1)
      expect(Repeater.where(call_sign: "N1PAH").count).to eq(5)
      repeater = Repeater.find_by(call_sign: "N1MYY") # This one didn't change.
      expect(repeater.band).to eq(Repeater::BAND_23CM)
      repeater = Repeater.find_by(call_sign: "AA1TT") # This one did
      expect(repeater.band).to eq(Repeater::BAND_1_25M)
      repeater = Repeater.find_by(call_sign: "N1PAH", tx_frequency: 145_000_001) # This one got deleted
      expect(repeater).to be(nil)
    end
  end
end
