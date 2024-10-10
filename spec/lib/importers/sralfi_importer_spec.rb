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

RSpec.describe SralfiImporter do
  include ImporterHelper

  before { Repeater.destroy_all }

  context "With a good source" do
    before do
      double_files(
        ["spec", "lib", "importers", "sralfi_importer_data"],
        { "https://automatic.sral.fi/api-v1.php?query=list" => "sralfi_export.json" })
    end

    it "should import" do
      Dir.mktmpdir("SralfiImporter") do |dir|
        expect do
          SralfiImporter.new(working_directory: dir).import
        end.to change { Repeater.count }.by(30)

        # Grab some repeaters and verify they were imported correctly.
        repeater = Repeater.find_sole_by(call_sign: "OH1RHU")
        expect(repeater.external_id).to eq("215")
        expect(repeater.name).to eq("Turku (RX) Lieto (TX)")
        expect(repeater.band).to eq(Repeater::BAND_10M)
        expect(repeater.operational).to eq(true)
        expect(repeater.rx_frequency).to eq(29_580_000)
        expect(repeater.tx_power).to eq(30)

        # Check a case where we get multiple repeaters with the same call sign.
        expect(Repeater.where(call_sign: "OH2RCH").count).to eq(6)
      end
    end

    it "should not import anything new on a second pass" do
      Dir.mktmpdir("SralfiImporter") do |dir|
        SralfiImporter.new(working_directory: dir).import

        # The second time we call it, it shouldn't re-download any files, nor create new repeaters
        expect do
          SralfiImporter.new(working_directory: dir).import
        end.to change { Repeater.count }.by(0)
      end
    end

    it "should respect the source values during import" do
      Dir.mktmpdir("SralfiImporter") do |dir|
        SralfiImporter.new(working_directory: dir).import

        # This repeater simulates a previously imported repeater that is no longer in the source files, so we should
        # delete it to avoid stale data.
        deleted = create(:repeater, :full, call_sign: "OH3RNE", tx_frequency: 145_000_001, source: SralfiImporter.source)

        # This repeater represents one where the upstream data changed and should be updated by the importer.
        changed = Repeater.find_sole_by(call_sign: "OH1RHU")
        changed_rx_frequency_was = changed.rx_frequency
        changed.rx_frequency = 28_000_123
        changed.save!

        # This repeater represents one where a secondary source imported first, and this importer will override it.
        secondary_source = Repeater.find_sole_by(call_sign: "OH2RCH", tx_frequency: 29_670_000)
        secondary_source_rx_frequency_was = secondary_source.rx_frequency
        secondary_source.rx_frequency = 28_000_123
        secondary_source.source = IrlpImporter.source
        secondary_source.save!

        # This repeater represents one that got taken over by the owner becoming a Repeater World user, that means the
        # source is now nil. This should never again be overwritten by the importer.
        independent = Repeater.find_sole_by(call_sign: "OH3RTR")
        independent_rx_frequency = independent.rx_frequency = 50_000_123
        independent.source = nil
        independent.save!

        # Run the import and verify we removed one repeater but otherwise made no changes.
        expect do
          SralfiImporter.new(working_directory: dir).import
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
        expect(secondary_source.source).to eq(SralfiImporter.source)

        # This one didn't change.
        independent.reload
        expect(independent.rx_frequency).to eq(independent_rx_frequency)
      end
    end
  end
end
