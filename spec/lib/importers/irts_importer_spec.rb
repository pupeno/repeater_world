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
  it "should import" do
    files = {"https://www.irts.ie/cgi/repeater.cgi?printable" => "irts.html"}

    files.each do |url, local_file|
      file = double("file")
      local_file = Rails.root.join("spec", "factories", "irts_importer_data", local_file)
      expect(file).to receive(:open).and_return(File.new(local_file))
      expect(URI).to receive(:parse).with(url).and_return(file)
    end

    Dir.mktmpdir("IrtsImporter") do |dir|
      expect do
        IrtsImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(44)

      expect(Repeater.where(call_sign: "EI0IPG").count).to eq(1)

      repeater = Repeater.find_sole_by(call_sign: "EI0IPG")
      expect(repeater.name).to eq("EI0IPG")
      expect(repeater.band).to eq(Repeater::BAND_10M)
      expect(repeater.tx_frequency).to eq(29_680_000)
      expect(repeater.rx_frequency).to eq(29_580_000)

      # The second time we call it, it shouldn't re-download any files, nor create new
      # repeaters
      expect do
        IrtsImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(0)

      # Some repeaters change, some get disconnected from the source, other's don't.
      repeater = Repeater.find_by(call_sign: "EI4SMR")
      repeater.rx_frequency = 1_000_000
      repeater.source = nil
      repeater.redistribution_limitations = nil
      repeater.save!
      repeater = Repeater.find_by(call_sign: "EI4SNR")
      repeater.rx_frequency = 1_000_000
      repeater.save!
      create(:repeater, :full, call_sign: "EI2TRR", tx_frequency: 145_000_001, source: IrtsImporter.source)

      # The third time we call it, it shouldn't re-download any files, nor create new
      # repeaters, but some get updated, some don't, and some get deleted.
      expect(Repeater.where(call_sign: "EI2TRR").count).to eq(2)
      expect do
        IrtsImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(-1)
      expect(Repeater.where(call_sign: "EI2TRR").count).to eq(1)
      repeater = Repeater.find_by(call_sign: "EI4SMR") # This one didn't change.
      expect(repeater.rx_frequency).to eq(1_000_000)
      repeater = Repeater.find_by(call_sign: "EI4SNR") # This one did
      expect(repeater.rx_frequency).to eq(70_475_000)
      repeater = Repeater.find_by(call_sign: "EI2TRR", tx_frequency: 145_000_001) # This one got deleted
      expect(repeater).to be(nil)
    end
  end
end
