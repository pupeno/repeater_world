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

class FasmaImporter < Importer
  def self.source
    "https://fasma.org/coordination/listings/"
  end

  private

  EXPORT_URLS = [
    "https://plots.fasma.org/listings/FASMA-All-Coordinated-Repeaters.csv",
    "https://plots.fasma.org/listings/FASMA-All-Uncoordinated-Repeaters.csv"
  ]

  # Columns
  OUTPUT = 0
  INPUT = 1
  CTCSS = 2
  CALL_SIGN = 3
  LOCATION = 4
  SPONSOR = 5
  STATUS = 6
  NOTES = 7
  STATION_TYPE = 8

  def import_all_repeaters
    EXPORT_URLS.each do |export_url|
      local_file_name = export_url.split("/").last
      file_name = download_file(export_url, local_file_name)
      file_contents = File.read(file_name)
      file_contents.gsub!("\"Robert \"Bob\" Schneider, W2HVL\"", "\"Robert \"\"Bob\"\" Schneider, W2HVL\"")
      csv_file = CSV.parse(file_contents, headers: true)
      csv_file.each_with_index do |raw_repeater, line_number|
        yield(raw_repeater, line_number)
      end
    end
  end

  GMRS_REPEATER_FREQUENCIES = [
    462_550_000,
    462_575_000,
    462_600_000,
    462_625_000,
    462_650_000,
    462_675_000,
    462_700_000,
    462_725_000
  ]

  def call_sign_and_tx_frequency(raw_repeater)
    tx_freq = raw_repeater["output"].to_d * 10**6
    if tx_freq == 0.0
      @ignored_due_to_invalid_count += 1
      return nil
    elsif tx_freq.in?(GMRS_REPEATER_FREQUENCIES) # Not importing GMRS frequencies yet.
      @ignored_due_to_invalid_count += 1
      return nil
    end
    [raw_repeater["callsign"].strip.upcase, tx_freq]
  end

  def import_repeater(raw_repeater, repeater)
    repeater.band = RepeaterUtils.band_for_frequency(repeater.tx_frequency)
    repeater.rx_frequency = raw_repeater["input"].to_d * 10**6
    if !RepeaterUtils.is_frequency_in_band?(repeater.rx_frequency, repeater.band)
      repeater.cross_band = true
    end

    repeater.notes = ""

    # TODO: What is emission 1 and 2? How do import them properly?
    repeater.notes += "Emission1: #{raw_repeater[:emission1]}\n"
    repeater.notes += "Emission2: #{raw_repeater[:emission2]}\n"

    if raw_repeater["ctcssIn"].present? && raw_repeater["ctcssIn"].strip != "NULL"
      repeater.fm = true
      repeater.fm_ctcss_tone = raw_repeater["ctcssIn"].to_d
      if repeater.fm_ctcss_tone == "206.5".to_d # Invalid
        repeater.fm_ctcss_tone = "203.5".to_d # Assuming a typo.
      end
      # TODO: import raw_repeater["ctcssOut"]?
      if raw_repeater["ctcssOut"].present? && raw_repeater["ctcssOut"] != raw_repeater["ctcssIn"]
        repeater.notes += "CTCSS IN: #{raw_repeater["ctcssIn"]}\nCTCSS OUT: #{raw_repeater["ctcssOut"]}\n"
      end
    end

    if raw_repeater[:dmrCc1].present? && raw_repeater[:dmrCc1].strip != "NULL"
      repeater.dmr = true
      repeater.dmr_color_code = raw_repeater[:dmrCc1].to_d
      # TODO: what are dmrGc1, dmrCc2, and dmrGc2?
      repeater.notes += "DMR GC1: #{raw_repeater[:dmrGc1]}\n" if raw_repeater[:dmrGc1].present?
      repeater.notes += "DMR CC2: #{raw_repeater[:dmrCc1]}\n" if raw_repeater[:dmrCc1].present?
      repeater.notes += "DMR GC2: #{raw_repeater[:dmrGc2]}\n" if raw_repeater[:dmrGc2].present?
    end

    if raw_repeater["fusion"].present? && raw_repeater["fusion"] == "1"
      repeater.fusion = true
      # TODO: import fusionDsq
      repeater.notes += "Fusion DSQ: #{raw_repeater["fusion"]}\n"
    end

    if raw_repeater["nxdnRan"].present? && raw_repeater["nxdnRan"].strip != "NULL"
      repeater.nxdn = true
      # TODO: import nxdnRan
      repeater.notes += "NXDN Ran: #{raw_repeater["nxdnRan"]}\n"
    end

    if raw_repeater[:p25NacOut].present? && raw_repeater[:p25NacOut].strip != "NULL"
      repeater.p25 = true
      # TODO: import p25NacOut, p25NacIn, and p25Phase1
      repeater.notes += "P25 NAC OUT: #{raw_repeater[:p25NacOut]}\nP25 NAC IN: #{raw_repeater[:p25NacIn]}\nP25 Phase 1: #{raw_repeater[:p25Phase1]}"
    end

    # Location
    repeater.input_locality = raw_repeater["city"].strip
    repeater.input_region = "Florida"
    repeater.input_country_id = "us"
    repeater.input_latitude = raw_repeater["latitude"].to_d if raw_repeater["latitude"].present?
    repeater.input_longitude = raw_repeater["longitude"].to_d if raw_repeater["longitude"].present?

    repeater.tx_antenna = raw_repeater["antenna"]
    repeater.rx_antenna = raw_repeater["antenna"]
    repeater.tx_power = raw_repeater["erp"].to_d
    repeater.altitude_agl = raw_repeater["agl"].to_d if raw_repeater["agl"].present? # What's the actual unit here, meter or feet?
    repeater.bandwidth = raw_repeater["chanSize"].to_d

    repeater.keeper = raw_repeater["holder"]
    repeater.web_site = raw_repeater["url"]

    repeater.external_id = raw_repeater["recordId"]
    repeater.source = self.class.source

    repeater.save!
    repeater
  end
end
