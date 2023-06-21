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

RSpec.describe IrlpImporter do
  before do
    Repeater.delete_all
    files = {"https://status.irlp.net/nohtmlstatus.txt.bz2" => "irlp.tsv.bz2"}
    files.each do |url, local_file|
      file = double("file")
      local_file = Rails.root.join("spec", "factories", "irlp_importer_data", local_file)
      expect(file).to receive(:open).and_return(File.new(local_file))
      expect(URI).to receive(:parse).with(url).and_return(file)
    end
  end

  it "should import" do
    Dir.mktmpdir("IrlpImporter") do |dir|
      expect do
        IrlpImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(936)

      # Grab some repeaters and verify they were imported correctly.
      repeater = Repeater.find_sole_by(call_sign: "VE7ISC")
      expect(repeater.name).to eq("Nanaimo VE7ISC")
      expect(repeater.band).to eq(Repeater::BAND_2M)
      expect(repeater.tx_frequency).to eq(146_640_000)
      expect(repeater.rx_frequency).to eq(146_040_000)

      # Check a case where we get multiple repeaters with the same call sign.
      expect(Repeater.where(call_sign: "K5NX").count).to eq(4)
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
      will_delete = create(:repeater, :full, call_sign: "VE7RHS", tx_frequency: 145_000_001, source: IrlpImporter.source)

      # This repeater represents one where the upstream data changed and should be updated by the importer.
      will_update = Repeater.find_by(call_sign: "VE7RVN")
      will_update.rx_frequency = 1_000_000
      will_update.save!

      # This repeater represents one that got taken over by the owner becoming a Repeater World user, that means the
      # source is now nil. This should never again be overwritten by the importer.
      wont_update = Repeater.find_by(call_sign: "VE7BYN")
      wont_update.rx_frequency = 1_000_000
      wont_update.source = nil
      wont_update.save!

      # Run the import and verify we removed one repeater but otherwise made no changes.
      expect do
        IrlpImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(-1)
        .and change { Repeater.where(call_sign: will_delete.call_sign, tx_frequency: will_delete.tx_frequency).count }.by(-1)

      # This one got deleted
      expect { will_delete.reload }.to raise_error(ActiveRecord::RecordNotFound)

      # This got updated.
      will_update.reload
      expect(will_update.rx_frequency).to eq(449_275_000)

      # This one didn't change.
      wont_update.reload
      expect(wont_update.rx_frequency).to eq(1_000_000)
    end
  end
end
