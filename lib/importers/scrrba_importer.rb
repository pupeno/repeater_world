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

class ScrrbaImporter < Importer
  def self.source
    "https://www.scrrba.org"
  end

  private

  EXPORT_URLS = [
    "https://www.scrrba.org/BandPlans/Open10mRepeaters.html",
    "https://www.scrrba.org/BandPlans/Open6mRepeaters.html",
    "https://www.scrrba.org/BandPlans/Open70cmRepeaters.html",
    "https://www.scrrba.org/BandPlans/Open33cmRepeaters.html",
    "https://www.scrrba.org/BandPlans/Open23cmRepeaters.html"
  ]

  # Columns
  OUTPUT = 0
  MODE_OR_ACCESS = 1
  CALL_SIGN = 2
  LOCATION = 3

  def import_all_repeaters
    EXPORT_URLS.each do |export_url|
      local_file_name = export_url.split("/").last
      file_name = download_file(export_url, local_file_name)

      doc = Nokogiri::HTML(File.read(file_name))
      table = doc.at("table[border=2]")
      table.search("tr").each_with_index do |row, index|
        row = row.search("td")
        row = row.map { |cell| cell.text.strip.gsub(/\s+/, ' ') }
        if row[OUTPUT].blank? || row[OUTPUT] == "Frequency (MHz)" ||
          row[CALL_SIGN].blank? || row[CALL_SIGN] == "--"
          next # Not really repeater lines.
        end
        yield(row, "#{local_file_name}:#{index}")
      end
    end
  end

  def call_sign_and_tx_frequency(raw_repeater)
    [raw_repeater[CALL_SIGN].upcase,
     raw_repeater[OUTPUT].to_f * 10 ** 6]
  end

  def import_repeater(raw_repeater, repeater)
    repeater.band = RepeaterUtils.band_for_frequency(repeater.tx_frequency)

    repeater.rx_frequency = if repeater.band == Repeater::BAND_10M
                              repeater.tx_frequency - 100_000
                            elsif repeater.band == Repeater::BAND_6M
                              repeater.tx_frequency - 500_000
                            elsif repeater.band == Repeater::BAND_70CM
                              repeater.tx_frequency - 5_000_000
                            elsif repeater.band == Repeater::BAND_33CM
                              repeater.tx_frequency - 25_000_000
                            elsif repeater.band == Repeater::BAND_23CM
                              repeater.tx_frequency - 12_000_000
                            end
    repeater.fm = true
    if raw_repeater[MODE_OR_ACCESS] == "103.8"
      repeater.fm_ctcss_tone = 103.5 # Guessing it's a typo.
    elsif raw_repeater[MODE_OR_ACCESS].in? ["DMR CC1"]
      repeater.fm = false
      repeater.dmr = true
      repeater.dmr_color_code = 1
    elsif raw_repeater[MODE_OR_ACCESS].in? ["DMR CC2"]
      repeater.fm = false
      repeater.dmr = true
      repeater.dmr_color_code = 2
    elsif raw_repeater[MODE_OR_ACCESS].in? ["DMR CC 3"]
      repeater.fm = false
      repeater.dmr = true
      repeater.dmr_color_code = 3
    elsif raw_repeater[MODE_OR_ACCESS].in? ["DMR"]
      repeater.fm = false
      repeater.dmr = true
    elsif raw_repeater[MODE_OR_ACCESS].in? ["DSTAR", "D-STAR"]
      repeater.fm = false
      repeater.dstar = true
    elsif raw_repeater[MODE_OR_ACCESS].in? ["DPL 411", "DPL 532", "DPL 606", "DPL 311"]
      # TODO: find out exactly what this is. GMRS? Is that ham radio?
      repeater.fm = false
    elsif raw_repeater[MODE_OR_ACCESS].in? ["CS"]
      # TODO: what are these?
    elsif raw_repeater[MODE_OR_ACCESS].blank? || raw_repeater[MODE_OR_ACCESS].in?(["--"])
      # Nothing we can do here.
    else
      repeater.fm_ctcss_tone = raw_repeater[MODE_OR_ACCESS].to_f
    end
    repeater.input_locality = raw_repeater[LOCATION]
    repeater.input_region = "California"
    repeater.input_country_id = "us"

    repeater.source = self.class.source

    repeater.save!
    repeater
  end
end
