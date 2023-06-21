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
  before do
    Repeater.delete_all
    files = {"https://automatic.sral.fi/api-v1.php?query=list" => "sralfi_export.json"}
    files.each do |url, local_file|
      file = double("file")
      local_file = Rails.root.join("spec", "factories", "sralfi_importer_data", local_file)
      expect(file).to receive(:open).and_return(File.new(local_file))
      expect(URI).to receive(:parse).with(url).and_return(file)
    end
  end

  it "should import" do
    Dir.mktmpdir("SralfiImporter") do |dir|
      expect do
        SralfiImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(141)

      # Grab some repeaters and verify they were imported correctly.
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
      will_delete = create(:repeater, :full, call_sign: "OH3RNE", tx_frequency: 145_000_001, source: SralfiImporter::SOURCE)

      # This repeater represents one where the upstream data changed and should be updated by the importer.
      will_update = Repeater.find_by(call_sign: "OH1RAA")
      will_update.rx_frequency = 1_000_000
      will_update.save!

      # This repeater represents one that got taken over by the owner becoming a Repeater World user, that means the
      # source is now nil. This should never again be overwritten by the importer.
      wont_update = Repeater.find_by(call_sign: "OH0RAA")
      wont_update.rx_frequency = 1_000_000
      wont_update.source = nil
      wont_update.save!

      # Run the import and verify we removed one repeater but otherwise made no changes.
      expect do
        SralfiImporter.new(working_directory: dir).import
      end.to change { Repeater.count }.by(-1)
                     .and change { Repeater.where(call_sign: will_delete.call_sign, tx_frequency: will_delete.tx_frequency).count }.by(-1)

      # This one got deleted
      expect { will_delete.reload }.to raise_error(ActiveRecord::RecordNotFound)

      # This got updated.
      will_update.reload
      expect(will_update.rx_frequency).to eq(145_050_000)

      # This one didn't change.
      wont_update.reload
      expect(wont_update.rx_frequency).to eq(1_000_000)
    end
  end
end
