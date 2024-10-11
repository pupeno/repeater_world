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

class MetrocorImporter < Importer
  def self.source
    "https://www.metrocor.net/"
  end

  private

  EXPORT_URL = "https://www.metrocor.net/"

  TX_FREQUENCY = 0
  RX_FREQUENCY = 1
  CALL_SIGN = 2
  CITY = 3
  COUNTY = 4
  STATE = 5
  ACCESS_CODE = 6
  COMMENTS = 7

  FREQUENCY_REGEX = /Output:[^\d]+([\d.]+)Input:[^\d]+([\d.]+)/

  def import_all_repeaters
    file_name = download_file(EXPORT_URL, "metrocor.html")

    doc = Nokogiri::HTML(File.read(file_name))

    doc.search("article.blog-post table").each_with_index do |table, table_index|
      table.search("tr").each_with_index do |row, row_index|
        row = row.search("td")
        if row.empty? || row.first.text == "Output"
          next
        end
        yield(row, table_index * 1_000_000 + row_index)
      end
    end
  end

  def call_sign_and_tx_frequency(raw_repeater)
    call_sign = raw_repeater[CALL_SIGN].text.strip.upcase
    tx_frequency = raw_repeater[TX_FREQUENCY].text.to_d * 10 ** 6
    if call_sign == "KD2TM" && tx_frequency == 233_900_000 # Assuming it's a typo, otherwise it's outside the band.
      tx_frequency = 223_900_000
    elsif call_sign == "N2QJI" && tx_frequency == 282_400_000 # Assuming it's a typo, otherwise it's outside the band.
      tx_frequency = 1_282_400_000
    end
    [call_sign, tx_frequency]
  end

  def import_repeater(raw_repeater, repeater)
    repeater.rx_frequency = raw_repeater[RX_FREQUENCY].text.to_d * 10 ** 6
    if repeater.call_sign == "K2DIG" && repeater.tx_frequency == 1_253_000_000 # Assuming it's a typo, otherwise it's outside the band...
      repeater.rx_frequency = 1_253_000_000 # ...but can't figure out what the exact frequency is.
    end
    repeater.band = RepeaterUtils.band_for_frequency(repeater.tx_frequency)

    import_mode_access_code(repeater, raw_repeater[ACCESS_CODE].text.strip)

    repeater.input_locality = raw_repeater[CITY].text.strip
    repeater.input_region = figure_out_us_state(raw_repeater[STATE].text.strip)
    repeater.input_country_id = "us"

    repeater.notes = raw_repeater[COMMENTS].text.strip

    repeater.source = self.class.source

    repeater.save!
    repeater
  end

  def import_mode_access_code(repeater, access_code)
    # When a repeater changes mode, the old modes that are no longer there shouldn't remain set to true.
    repeater.disable_all_modes

    if access_code.blank? || access_code.in?(["None"])
      # Pure guesswork here:
      repeater.fm = true
      repeater.fm_tone_burst = true
    elsif access_code.to_d.to_s == access_code && access_code.to_d.in?(Repeater::CTCSS_TONES)
      repeater.fm = true
      repeater.fm_ctcss_tone = access_code.to_d
    elsif access_code.in? ["DSTAR", "Dstar"]
      repeater.dstar = true
    elsif access_code.in? ["C4FM"]
      repeater.fusion = true
    elsif access_code.in? ["DMR"]
      repeater.dmr = true
    elsif access_code.in? ["100"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 100.0
    elsif access_code.in? ["107.3"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 103.5
    elsif access_code.in? ["136,5"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 136.5
    elsif access_code.in? ["206.5"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 203.5
    elsif access_code.in? ["208.5"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 203.5
    elsif access_code.in? ["D123"]
      repeater.fm = true
      repeater.fm_dcs_code = 132
    elsif access_code.in? ["DPL 205"]
      repeater.fm = true
      repeater.fm_dcs_code = 205
    elsif access_code.in? ["DPL 245"]
      repeater.fm = true
      repeater.fm_dcs_code = 245
    elsif access_code.in? ["DPL 516"]
      repeater.fm = true
      repeater.fm_dcs_code = 516
    elsif access_code.in? ["DPL 606"]
      repeater.fm = true
      repeater.fm_dcs_code = 606
    elsif access_code.in? ["192.8/DPL255"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 192.8
      repeater.fm_dcs_code = 245
    elsif access_code.in? ["DMR / 74.4"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 74.4
      repeater.dmr = true
    elsif access_code.in? ["94.8/DMR"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 94.8
      repeater.dmr = true
    elsif access_code.in? ["DMR/141.3"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 141.3
      repeater.dmr = true
    elsif access_code.in? ["156.7/DMR"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 156.7
      repeater.dmr = true
    elsif access_code.in? ["DMR/203.5"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 203.5
      repeater.dmr = true
    elsif access_code.in? ["DMR/#1"]
      repeater.dmr = true
      repeater.dmr_color_code = 1
    elsif access_code.in? ["TRBO", "DPL 017"]
      # No idea what to do here, unknown or so wrong I can't correct them.
    else
      raise "Unexpected access code #{access_code} for repeater #{repeater}"
    end
  end
end
