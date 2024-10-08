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

RSpec.describe FasmaImporter do
  before do
    Repeater.destroy_all
    files = {
      "https://plots.fasma.org/listings/FASMA-All-Coordinated-Repeaters.csv" => "FASMA-All-Coordinated-Repeaters.csv",
      "https://plots.fasma.org/listings/FASMA-All-Uncoordinated-Repeaters.csv" => "FASMA-All-Uncoordinated-Repeaters.csv"
    }
    files.each do |url, local_file|
      file = double("file")
      local_file = Rails.root.join("spec", "lib", "importers", "fasma_importer_data", local_file)
      expect(file).to receive(:open).and_return(File.new(local_file))
      expect(URI).to receive(:parse).with(url).and_return(file)
    end
  end

  it "should import" do
    Dir.mktmpdir("FasmaImporter") do |dir|
      expect do
        FasmaImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(14)

      # Grab one repeater and verify it was imported correctly.
      repeater = Repeater.find_sole_by(call_sign: "KC4JHS")
      expect(repeater.name).to eq(nil)
      expect(repeater.band).to eq(Repeater::BAND_70CM)
      expect(repeater.tx_frequency).to eq(435_000_000)
      expect(repeater.rx_frequency).to eq(910_250_000)
    end
  end

  it "should not import anything new on a second pass" do
    Dir.mktmpdir("FasmaImporter") do |dir|
      FasmaImporter.new(working_directory: dir).import

      # The second time we call it, it shouldn't re-download any files, nor create new repeaters
      expect do
        FasmaImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(0)
    end
  end

  it "should respect the source values during import" do
    Dir.mktmpdir("FasmaImporter") do |dir|
      FasmaImporter.new(working_directory: dir).import

      # This repeater simulates a previously imported repeater that is no longer in the source files, so we should
      # delete it to avoid stale data.
      deleted = create(:repeater, :full, call_sign: "N1PAH", tx_frequency: 145_000_001, source: FasmaImporter.source)
      create(:suggested_repeater, repeater: deleted) # To simulated a suggested repeater on a repeater that gets deleted.

      # This repeater represents one where the upstream data changed and should be updated by the importer.
      # It should update frequency and modes, without crashing.
      changed = Repeater.find_sole_by(call_sign: "KC4JHS")
      changed_rx_frequency_was = changed.rx_frequency
      changed.fm = true
      changed.dstar = false
      changed.rx_frequency = 445_000_123
      changed.save!

      # This repeater represents one where a secondary source imported first, and this importer will override it.
      secondary_source = Repeater.find_sole_by(call_sign: "K4GET")
      secondary_source_rx_frequency_was = secondary_source.rx_frequency
      secondary_source.rx_frequency = 445_000_234
      secondary_source.source = IrlpImporter.source
      secondary_source.save!

      # This repeater represents one that got taken over by the owner becoming a Repeater World user, that means the
      # source is now nil. This should never again be overwritten by the importer.
      independent = Repeater.find_sole_by(call_sign: "AD4PS")
      independent_rx_frequency = independent.rx_frequency = 445_000_345
      independent.source = nil
      independent.save!

      # Run the import and verify we removed one repeater but otherwise made no changes.
      expect do
        FasmaImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(-1)
        .and change { Repeater.where(call_sign: deleted.call_sign, tx_frequency: deleted.tx_frequency).count }.by(-1)

      # This one got deleted
      expect { deleted.reload }.to raise_error(ActiveRecord::RecordNotFound)

      # This got updated.
      changed.reload
      expect(changed.rx_frequency).to eq(changed_rx_frequency_was)

      # This got updated.
      secondary_source.reload
      expect(secondary_source.rx_frequency).to eq(secondary_source_rx_frequency_was)
      expect(secondary_source.source).to eq(FasmaImporter.source)

      # This one didn't change.
      independent.reload
      expect(independent.rx_frequency).to eq(independent_rx_frequency)
    end
  end
end
