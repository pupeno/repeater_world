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
      end.to change { Repeater.count }.by(141)

      expect(Repeater.where(call_sign: "OH3RNE").count).to eq(5)

      repeater = Repeater.find_sole_by(call_sign: "OH3RNE", tx_frequency: 145_575_000, dmr: true)
      expect(repeater.external_id).to eq("801")
      expect(repeater.name).to eq("Tampere VHF DMR")
      expect(repeater.band).to eq(Repeater::BAND_2M)
      expect(repeater.operational).to eq(true)
      expect(repeater.rx_frequency).to eq(144_975_000)
      expect(repeater.tx_power).to eq(50)
      expect(repeater.dmr_color_code).to eq(1)
      expect(repeater.dmr_network).to eq("Brandmeister")

      repeater = Repeater.find_sole_by(call_sign: "OH3RNE", tx_frequency: 145_750_000, fm: true)
      expect(repeater.external_id).to eq("237")
      expect(repeater.name).to eq("Tampere Wide Area")
      expect(repeater.band).to eq(Repeater::BAND_2M)
      expect(repeater.operational).to eq(true)
      expect(repeater.rx_frequency).to eq(145_150_000)
      expect(repeater.tx_power).to eq(47)
      expect(repeater.fm_ctcss_tone).to eq(123)

      repeater = Repeater.find_sole_by(call_sign: "OH3RNE", tx_frequency: 434_850_000, fm: true)
      expect(repeater.external_id).to eq("286")
      expect(repeater.name).to eq("Tampere City")
      expect(repeater.band).to eq(Repeater::BAND_70CM)
      expect(repeater.operational).to eq(true)
      expect(repeater.rx_frequency).to eq(432_850_000)
      expect(repeater.tx_power).to eq(35)
      expect(repeater.fm_ctcss_tone).to eq(123)

      repeater = Repeater.find_sole_by(call_sign: "OH3RNE", tx_frequency: 434_550_000, dmr: true)
      expect(repeater.external_id).to eq("338")
      expect(repeater.name).to eq("Tampere Tesoma DMR")
      expect(repeater.band).to eq(Repeater::BAND_70CM)
      expect(repeater.operational).to eq(true)
      expect(repeater.rx_frequency).to eq(432_550_000)
      expect(repeater.tx_power).to eq(45)
      expect(repeater.dmr_color_code).to eq(1)
      expect(repeater.dmr_network).to eq("Brandmeister")

      repeater = Repeater.find_sole_by(call_sign: "OH3RNE", tx_frequency: 434_525_000, dmr: true)
      expect(repeater.external_id).to eq("701")
      expect(repeater.name).to eq("Tampere Hervanta DMR")
      expect(repeater.band).to eq(Repeater::BAND_70CM)
      expect(repeater.operational).to eq(true)
      expect(repeater.rx_frequency).to eq(432_525_000)
      expect(repeater.tx_power).to eq(45.0)
      expect(repeater.dmr_color_code).to eq(1)

      repeater = Repeater.find_sole_by(call_sign: "OH6RVC", tx_frequency: 1_297_425_000)
      expect(repeater.external_id).to eq("331")
      expect(repeater.name).to eq("Lapua")
      expect(repeater.web_site).to eq("http://www.oh6ac.net")

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
      create(:repeater, :full, call_sign: "OH3RNE", source: SralfiImporter::SOURCE)

      # The third time we call it, it shouldn't re-download any files, nor create new
      # repeaters, but some get updated, some don't, and some get deleted.
      expect(Repeater.where(call_sign: "OH3RNE").count).to eq(6)
      expect do
        SralfiImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(-1)
      expect(Repeater.where(call_sign: "OH3RNE").count).to eq(5)
      repeater = Repeater.find_by(call_sign: "OH0RAA") # This one didn't change.
      expect(repeater.band).to eq(Repeater::BAND_23CM)
      repeater = Repeater.find_by(call_sign: "OH1RAA") # This one did
      expect(repeater.band).to eq(Repeater::BAND_2M)
      repeater = Repeater.find_by(call_sign: "OH3RNE", tx_frequency: 145_000_000) # This one got deleted
      expect(repeater).to be(nil)
    end
  end
end
