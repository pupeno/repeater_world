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

RSpec.describe IrtsImporter do
  before do
    Repeater.delete_all
    files = {"https://www.irts.ie/cgi/repeater.cgi?printable" => "irts.html"}
    files.each do |url, local_file|
      file = double("file")
      local_file = Rails.root.join("spec", "factories", "irts_importer_data", local_file)
      expect(file).to receive(:open).and_return(File.new(local_file))
      expect(URI).to receive(:parse).with(url).and_return(file)
    end
  end

  it "should import" do
    Dir.mktmpdir("IrtsImporter") do |dir|
      expect do
        IrtsImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(44)

      # Grab one repeater and verify it was imported correctly.
      repeater = Repeater.find_sole_by(call_sign: "EI0IPG")
      expect(repeater.name).to eq("EI0IPG")
      expect(repeater.band).to eq(Repeater::BAND_10M)
      expect(repeater.tx_frequency).to eq(29_680_000)
      expect(repeater.rx_frequency).to eq(29_580_000)
    end
  end

  it "should not import anything new on a second pass" do
    Dir.mktmpdir("IrtsImporter") do |dir|
      IrtsImporter.new(working_directory: dir).import

      # It should not import anything new on a second pass and also it shouldn't re-download files.
      expect do
        IrtsImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(0)
    end
  end

  it "should respect the source values during import" do
    Dir.mktmpdir("IrtsImporter") do |dir|
      IrtsImporter.new(working_directory: dir).import

      # This repeater simulates a previously imported repeater that is no longer in the source files, so we should
      # delete it to avoid stale data.
      will_delete = "EI2TRR"
      create(:repeater, :full, call_sign: will_delete, tx_frequency: 145_000_001, source: IrtsImporter.source)

      # This repeater represents one that got taken over by the owner becoming a Repeater World user, that means the
      # source is now nil. This should never again be overwritten by the importer.
      wont_update = "EI4SMR"
      repeater = Repeater.find_by(call_sign: wont_update)
      repeater.rx_frequency = 1_000_000
      repeater.source = nil
      repeater.save!

      # This repeater represents one where the upstream data changed and should be updated by the importer.
      will_update = "EI4SNR"
      repeater = Repeater.find_by(call_sign: will_update)
      repeater.rx_frequency = 1_000_000
      repeater.save!

      # Run the import and verify we removed one repeater but otherwise made no changes.
      expect do
        IrtsImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(-1)
        .and change { Repeater.where(call_sign: will_delete, tx_frequency: 145_000_001).count }.by(-1)

      # This one got deleted
      repeater = Repeater.find_by(call_sign: will_delete, tx_frequency: 145_000_001)
      expect(repeater).to be(nil)

      # This one didn't change.
      repeater = Repeater.find_by(call_sign: wont_update)
      expect(repeater.rx_frequency).to eq(1_000_000)

      # This got updated.
      repeater = Repeater.find_by(call_sign: will_update)
      expect(repeater.rx_frequency).to eq(70_475_000)
    end
  end
end
