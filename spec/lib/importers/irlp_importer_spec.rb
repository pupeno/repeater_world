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

RSpec.describe IrlpImporter do
  it "should import" do
    files = {"https://status.irlp.net/nohtmlstatus.txt.bz2" => "irlp.tsv.bz2"}

    files.each do |url, local_file|
      file = double("file")
      local_file = Rails.root.join("spec", "factories", "irlp_importer_data", local_file)
      expect(file).to receive(:open).and_return(File.new(local_file))
      expect(URI).to receive(:parse).with(url).and_return(file)
    end

    Dir.mktmpdir("IrlpImporter") do |dir|
      expect do
        IrlpImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(936)

      expect(Repeater.where(call_sign: "VE7RHS").count).to eq(3)

      repeater = Repeater.find_sole_by(call_sign: "VE7ISC")
      expect(repeater.name).to eq("Nanaimo VE7ISC")
      expect(repeater.band).to eq(Repeater::BAND_2M)
      expect(repeater.tx_frequency).to eq(146_640_000)
      expect(repeater.rx_frequency).to eq(146_040_000)

      # The second time we call it, it shouldn't re-download any files, nor create new
      # repeaters
      expect do
        IrlpImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(0)

      # Some repeaters change, some get disconnected from the source, other's don't.
      repeater = Repeater.find_by(call_sign: "VE7BYN")
      repeater.rx_frequency = 1_000_000
      repeater.source = nil
      repeater.redistribution_limitations = nil
      repeater.save!
      repeater = Repeater.find_by(call_sign: "VE7RVN")
      repeater.rx_frequency = 1_000_000
      repeater.save!
      create(:repeater, :full, call_sign: "VE7RHS", tx_frequency: 145_000_001, source: IrlpImporter.source)

      # The third time we call it, it shouldn't re-download any files, nor create new
      # repeaters, but some get updated, some don't, and some get deleted.
      expect(Repeater.where(call_sign: "VE7RHS").count).to eq(4)
      expect do
        IrlpImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(-1)
      expect(Repeater.where(call_sign: "VE7RHS").count).to eq(3)
      repeater = Repeater.find_by(call_sign: "VE7BYN") # This one didn't change.
      expect(repeater.rx_frequency).to eq(1_000_000)
      repeater = Repeater.find_by(call_sign: "VE7RVN") # This one did
      expect(repeater.rx_frequency).to eq(449_275_000)
      repeater = Repeater.find_by(call_sign: "VE7RHS", tx_frequency: 145_000_001) # This one got deleted
      expect(repeater).to be(nil)
    end
  end
end
