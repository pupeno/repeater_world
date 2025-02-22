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

RSpec.describe IrlpImporter do
  include ImporterHelper

  before { Repeater.destroy_all }

  context "With a good source" do
    before do
      double_files(
        ["spec", "lib", "importers", "irlp_importer_data", "good"],
        {"https://status.irlp.net/nohtmlstatus.txt.bz2" => "irlp.tsv.bz2"}
      )
    end

    it "should import" do
      Dir.mktmpdir("IrlpImporter") do |dir|
        expect do
          IrlpImporter.new(working_directory: dir).import
        end.to change { Repeater.count }.by(25)

        # Grab some repeaters and verify they were imported correctly.
        repeater = Repeater.find_sole_by(call_sign: "VE7RHS")
        expect(repeater.name).to eq(nil)
        expect(repeater.band).to eq(Repeater::BAND_2M)
        expect(repeater.tx_frequency).to eq(145_270_000)
        expect(repeater.rx_frequency).to eq(144_670_000)

        # Check a case where we get multiple repeaters with the same call sign.
        expect(Repeater.where(call_sign: "K5NX").count).to eq(2)
      end
    end

    it "should not import anything new on a second pass" do
      Dir.mktmpdir("IrlpImporter") do |dir|
        IrlpImporter.new(working_directory: dir).import

        # The second time we call it, it shouldn't re-download any files, nor create new repeaters
        expect do
          IrlpImporter.new(working_directory: dir).import
        end.to change { Repeater.count }.by(0)
      end
    end

    it "should respect the source values during import" do
      Dir.mktmpdir("IrlpImporter") do |dir|
        IrlpImporter.new(working_directory: dir).import

        # This repeater simulates a previously imported repeater that is no longer in the source files, so we should
        # delete it to avoid stale data.
        deleted = create(:repeater, :full, call_sign: "VE7RHS", tx_frequency: 145_000_001, source: IrlpImporter.source,
          irlp_node_number: 9999)

        # This repeater represents one where the upstream data changed and should be updated by the importer.
        changed = Repeater.find_sole_by(call_sign: "VE7RHS", irlp_node_number: 1000)
        changed_rx_frequency_was = changed.rx_frequency
        changed.rx_frequency = 144_000_123
        changed.save!

        # This repeater represents one that got taken over by the owner becoming a Repeater World user, that means the
        # source is now nil. This should never again be overwritten by the importer.
        independent = Repeater.find_sole_by(call_sign: "W7NJN")
        independent_rx_frequency = independent.rx_frequency = 144_000_123
        independent.source = nil
        independent.save!

        # Run the import and verify we removed one repeater but otherwise made no changes.
        expect do
          IrlpImporter.new(working_directory: dir).import
        end.to change { Repeater.count }.by(-1)
          .and change { Repeater.where(call_sign: deleted.call_sign, tx_frequency: deleted.tx_frequency).count }.by(-1)

        # This one got deleted
        expect { deleted.reload }.to raise_error(ActiveRecord::RecordNotFound)

        # This got updated.
        changed.reload
        expect(changed.rx_frequency).to eq(changed_rx_frequency_was)

        # This one didn't change.
        independent.reload
        expect(independent.rx_frequency).to eq(independent_rx_frequency)
      end
    end
  end

  it "should not import with an unknown access code" do
    double_files(
      ["spec", "lib", "importers", "irlp_importer_data", "unknown_access_code"],
      {"https://status.irlp.net/nohtmlstatus.txt.bz2" => "irlp.tsv.bz2"}
    )

    Dir.mktmpdir("IrlpImporter") do |dir|
      expect do
        IrlpImporter.new(working_directory: dir).import
      end.to raise_error(RuntimeError, /Unknown access code:/)
    end
  end

  it "should not import with a country that doesn't exist" do
    double_files(
      ["spec", "lib", "importers", "irlp_importer_data", "country_does_not_exist"],
      {"https://status.irlp.net/nohtmlstatus.txt.bz2" => "irlp.tsv.bz2"}
    )

    Dir.mktmpdir("IrlpImporter") do |dir|
      expect do
        IrlpImporter.new(working_directory: dir).import
      end.to raise_error(RuntimeError, "The country Netherlands Antilles doesn't exist anymore.")
    end
  end
end
