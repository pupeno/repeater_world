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
require_relative "importer_helper"

RSpec.describe NerepeatersImporter do
  include ImporterHelper

  before { Repeater.destroy_all }

  context "With a good source" do
    before do
      double_files(
        ["spec", "lib", "importers", "nerepeaters_importer_data", "good"],
        {"http://www.nerepeaters.com/NERepeaters.php" => "nerepeaters.csv"}
      )
    end

    it "should import" do
      Dir.mktmpdir("NerepeatersImporter") do |dir|
        expect do
          NerepeatersImporter.new(working_directory: dir).import
        end.to change { Repeater.count }.by(91)

        # Grab one repeater and verify it was imported correctly.
        repeater = Repeater.find_sole_by(call_sign: "KB1CDI")
        expect(repeater.name).to eq(nil)
        expect(repeater.band).to eq(Repeater::BAND_10M)
        expect(repeater.tx_frequency).to eq(29_640_000)
        expect(repeater.rx_frequency).to eq(29_540_000)

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
        deleted = create(:repeater, :full, call_sign: "N1PAH", tx_frequency: 145_000_001, source: NerepeatersImporter.source)
        create(:suggested_repeater, repeater: deleted) # To simulated a suggested repeater on a repeater that gets deleted.

        # This repeater represents one where the upstream data changed and should be updated by the importer.
        # It should update frequency and modes, without crashing.
        changed = Repeater.find_sole_by(call_sign: "AA1HD", tx_frequency: 145260000, fm: nil, dstar: true)
        changed_rx_frequency_was = changed.rx_frequency
        changed.fm = true
        changed.dstar = false
        changed.rx_frequency = 144_000_123
        changed.save!

        # This repeater represents one where a secondary source imported first, and this importer will override it.
        secondary_source = Repeater.find_sole_by(call_sign: "W1BST")
        secondary_source_rx_frequency_was = secondary_source.rx_frequency
        secondary_source.rx_frequency = 50_000_123
        secondary_source.source = IrlpImporter.source
        secondary_source.save!

        # This repeater represents one that got taken over by the owner becoming a Repeater World user, that means the
        # source is now nil. This should never again be overwritten by the importer.
        independent = Repeater.find_sole_by(call_sign: "W1AEC", tx_frequency: 147_000_000)
        independent_rx_freq = independent.rx_frequency = 144_000_321
        independent.source = nil
        independent.save!

        # Run the import and verify we removed one repeater but otherwise made no changes.
        expect do
          NerepeatersImporter.new(working_directory: dir).import
        end.to change { Repeater.count }.by(-1)
          .and change { Repeater.where(call_sign: deleted.call_sign, tx_frequency: deleted.tx_frequency).count }.by(-1)

        # This one got deleted
        expect { deleted.reload }.to raise_error(ActiveRecord::RecordNotFound)

        # This got updated.
        changed.reload
        expect(changed.fm).to eq(nil)
        expect(changed.dstar).to eq(true)
        expect(changed.rx_frequency).to eq(changed_rx_frequency_was)

        # This got updated.
        secondary_source.reload
        expect(secondary_source.rx_frequency).to eq(secondary_source_rx_frequency_was)
        expect(secondary_source.source).to eq(NerepeatersImporter.source)

        # This one didn't change.
        independent.reload
        expect(independent.rx_frequency).to eq(independent_rx_freq)
      end
    end
  end

  it "should not import when offset can't be found" do
    double_files(
      ["spec", "lib", "importers", "nerepeaters_importer_data", "unfindable_offset"],
      {"http://www.nerepeaters.com/NERepeaters.php" => "nerepeaters.csv"}
    )
    Dir.mktmpdir("NerepeatersImporter") do |dir|
      expect do
        NerepeatersImporter.new(working_directory: dir).import
      end.to raise_error(RuntimeError, /Can't find offset/)
    end
  end

  it "should not import when rx freq can't be figured out for custom offset" do
    double_files(
      ["spec", "lib", "importers", "nerepeaters_importer_data", "unfindable_custom_offset"],
      {"http://www.nerepeaters.com/NERepeaters.php" => "nerepeaters.csv"}
    )
    Dir.mktmpdir("NerepeatersImporter") do |dir|
      expect do
        NerepeatersImporter.new(working_directory: dir).import
      end.to raise_error(RuntimeError, /Can't figure out rx frequency for offset/)
    end
  end

  it "should not import with an unknown offset symbol" do
    double_files(
      ["spec", "lib", "importers", "nerepeaters_importer_data", "unexpected_offset_symbol"],
      {"http://www.nerepeaters.com/NERepeaters.php" => "nerepeaters.csv"}
    )
    Dir.mktmpdir("NerepeatersImporter") do |dir|
      expect do
        NerepeatersImporter.new(working_directory: dir).import
      end.to raise_error(RuntimeError, /Unexpected offset/)
    end
  end

  it "should not import with an unknown mode" do
    double_files(
      ["spec", "lib", "importers", "nerepeaters_importer_data", "unknown_mode"],
      {"http://www.nerepeaters.com/NERepeaters.php" => "nerepeaters.csv"}
    )
    Dir.mktmpdir("NerepeatersImporter") do |dir|
      expect do
        NerepeatersImporter.new(working_directory: dir).import
      end.to raise_error(RuntimeError, /Unknown mode /)
    end
  end

  it "should not import with an unknown access code" do
    double_files(
      ["spec", "lib", "importers", "nerepeaters_importer_data", "unknown_access_code"],
      {"http://www.nerepeaters.com/NERepeaters.php" => "nerepeaters.csv"}
    )
    Dir.mktmpdir("NerepeatersImporter") do |dir|
      expect do
        NerepeatersImporter.new(working_directory: dir).import
      end.to raise_error(RuntimeError, /Unknown access code/)
    end
  end
end
