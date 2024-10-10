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

class IrtsImporter < Importer
  def self.source
    "https://www.irts.ie/cgi/repeater.cgi"
  end

  private

  EXPORT_URL = "https://www.irts.ie/cgi/repeater.cgi?printable"

  CHANNEL = 0
  FREQUENCY = 1
  CALL_SIGN = 2
  ACCESS = 3
  LOCATION = 4
  NOTES = 5

  FREQUENCY_REGEX = /Output:[^\d]+([\d.]+)Input:[^\d]+([\d.]+)/

  def import_all_repeaters
    file_name = download_file(EXPORT_URL, "irts.html")

    doc = Nokogiri::HTML(File.read(file_name))
    table = doc.at("table")

    table.search("tr").each_with_index do |row, index|
      row = row.search("td")
      next if row.empty?
      yield(row, index)
    end
  end

  def call_sign_and_tx_frequency(raw_repeater)
    [raw_repeater[CALL_SIGN].text.strip.upcase,
      raw_repeater[FREQUENCY].text.scan(FREQUENCY_REGEX).flatten.first.to_f * 10**6]
  end

  def import_repeater(raw_repeater, repeater)
    repeater.name = nil # It used to be repeater.call_sign, it needs to be blanked.
    repeater.channel = raw_repeater[CHANNEL].text.strip
    repeater.rx_frequency = raw_repeater[FREQUENCY].text.scan(FREQUENCY_REGEX).flatten.second.to_f * 10**6
    repeater.band = RepeaterUtils.band_for_frequency(repeater.tx_frequency)

    import_mode_access_code(repeater, raw_repeater[ACCESS].text.strip, raw_repeater[NOTES].text.strip)
    import_location(repeater, raw_repeater[LOCATION])
    repeater.notes = raw_repeater[NOTES].text.strip

    repeater.input_country_id = "ie"
    repeater.source = self.class.source

    repeater.save!
    repeater
  end

  def import_mode_access_code(repeater, access, notes)
    # When a repeater changes mode, the old modes that are no longer there shouldn't remain set to true.
    repeater.disable_all_modes

    access_codes = access.split("/")
    access_codes.each do |access_code|
      if access_code.to_d == "1750.0".to_d
        repeater.fm = true
        repeater.fm_tone_burst = true
      elsif access_code.to_d.in? Repeater::CTCSS_TONES
        repeater.fm = true
        repeater.fm_ctcss_tone = access_code.to_d
      elsif access_code.to_d == 110 # Assuming it's a typo and should be 110.9.
        repeater.fm = true
        repeater.fm_ctcss_tone = "110.9".to_d
      elsif access_code.strip == "Wires X"
        repeater.fusion = true # Assuming Wires X means System Fusion.
      elsif access_code.strip == "C4FM"
        repeater.fusion = true
      elsif access_code.strip == "Carrier"
        repeater.fm = true # What is Carrier? Just pressing the PTT with no tone at all?
      elsif access_code.strip == "MMDVM"
        # This seems to just indicate that it's multi mode, but not how to access.
      elsif access_code.strip == "DMR CC1"
        repeater.dmr = true
        repeater.dmr_color_code = 1
      elsif access_code.strip == "DMR CC2"
        repeater.dmr = true
        repeater.dmr_color_code = 2
      elsif access_code.strip == "Dstar"
        repeater.dstar = true
      else
        raise "Unknown access code #{access_code}"
      end
    end
    if "FM".in? notes
      repeater.fm = true
    end
    if "DStar".in? notes
      repeater.dstar = true
    end
    if "Fusion".in?(notes) || "C4FM".in?(notes)
      repeater.fusion = true
    end
    if "DMR".in? notes
      repeater.dmr = true
    end
    if "NXDN".in? notes
      repeater.nxdn = true
    end
  end

  def import_location(repeater, location)
    location = location.xpath("text()").map(&:text)

    repeater.input_grid_square = location.last

    address = location[0..-2].join(",")
    address = address.split(",").map { |x| x.strip.gsub(/\s+/, " ").tr("\u00A0", " ") }

    if address.size == 1
      if address[0].start_with? "Co"
        repeater.input_locality = nil
        repeater.input_region = address.first
      else
        repeater.input_locality = address.first
        repeater.input_region = nil
      end
    else
      repeater.input_locality = address[0..-2].join(",")
      repeater.input_region = address[-1]
    end
  end
end
