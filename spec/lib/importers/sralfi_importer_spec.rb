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

RSpec.describe SralfiImporter do
  it "should import" do
    files = {"https://automatic.sral.fi/api-v1.php?query=list" => "sralfi_export.json"}

    files.each do |url, local_file|
      file = double("file")
      local_file = Rails.root.join("spec", "factories", "sralfi_importer_data", local_file)
      expect(file).to receive(:open).and_return(File.new(local_file))
      expect(URI).to receive(:parse).with(url).and_return(file)
    end

    Dir.mktmpdir("SralfiImporter") do |dir|
      expect do
        SralfiImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(113)

      repeater = Repeater.find_by(call_sign: "OH0RAA")
      expect(repeater.name).to eq("Dalkarby")
      expect(repeater.band).to eq(Repeater::BAND_2M)
      expect(repeater.operational).to eq(true)
      expect(repeater.tx_frequency).to eq(145675000)
      expect(repeater.rx_frequency).to eq(145075000)
      expect(repeater.fm).to eq(true)

      # The second time we call it, it shouldn't re-download any files, nor create new
      # repeaters
      expect do
        SralfiImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(0)

      # Some repeaters change, some get disconnected from the source, other's don't.
      repeater = Repeater.find_by(call_sign: "OH0RAA")
      repeater.band = Repeater::BAND_23CM
      repeater.source = nil
      repeater.redistribution_limitations = nil
      repeater.save!
      repeater = Repeater.find_by(call_sign: "OH1RAA")
      repeater.band = Repeater::BAND_23CM
      repeater.save!

      # The third time we call it, it shouldn't re-download any files, nor create new
      # repeaters, but some get updated and some don't.
      expect do
        SralfiImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(0)
      repeater = Repeater.find_by(call_sign: "OH0RAA") # This one didn't change.
      expect(repeater.band).to eq(Repeater::BAND_23CM)
      repeater = Repeater.find_by(call_sign: "OH1RAA") # This one did
      expect(repeater.band).to eq(Repeater::BAND_2M)
    end
  end
end
