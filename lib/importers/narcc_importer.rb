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

class NarccImporter < Importer
  def self.source
    "https://www.narcconline.org/narcc/repeater_list_menu.cfm"
  end

  private

  EXPORT_URLS = [
    "https://www.narcconline.org/narcc/Repeater_List_Menu.cfm?CZONE=All&SBAND=29&SType=All&Status=All",
    "https://www.narcconline.org/narcc/Repeater_List_Menu.cfm?CZONE=All&SBAND=52&SType=All&Status=All",
    "https://www.narcconline.org/narcc/Repeater_List_Menu.cfm?CZONE=All&SBAND=144&SType=All&Status=All",
    "https://www.narcconline.org/narcc/Repeater_List_Menu.cfm?CZONE=All&SBAND=220&SType=All&Status=All",
    "https://www.narcconline.org/narcc/Repeater_List_Menu.cfm?CZONE=All&SBAND=440&SType=All&Status=All",
    "https://www.narcconline.org/narcc/Repeater_List_Menu.cfm?CZONE=All&SBAND=902&SType=All&Status=All",
    "https://www.narcconline.org/narcc/Repeater_List_Menu.cfm?CZONE=All&SBAND=1240&SType=All&Status=All",
    "https://www.narcconline.org/narcc/Repeater_List_Menu.cfm?CZONE=All&SBAND=2000&SType=All&Status=All"]

  def import_data
    ignored_due_to_source_count = 0
    created_or_updated_ids = []
    repeaters_deleted_count = 0

    EXPORT_URLS.each do |export_url|
      file_name = download_file(export_url, "#{export_url.match(/SBAND=(\d+)/)[1]}.html")

      doc = Nokogiri::HTML(File.read(file_name))
      table = doc.at("table")
      table.search("tr").each do |row|
        row = row.search("td")
        next if row[1].nil? || row[0].text.strip == "Output" # Various header rows.

        action, imported_repeater = import_repeater(row)
        if action == :ignored_due_to_source
          ignored_due_to_source_count += 1
        elsif action == :ignored_due_to_broken_record
          # Nothing to do really. Should we track this?
        else
          created_or_updated_ids << imported_repeater.id
        end
      rescue
        raise "Failed to import record #{row}"
      end

      repeaters_deleted_count = Repeater.where(source: self.class.source).where.not(id: created_or_updated_ids).destroy_all
    end

    { created_or_updated_ids: created_or_updated_ids,
      ignored_due_to_source_count: ignored_due_to_source_count,
      ignored_due_to_invalid_count: 0,
      repeaters_deleted_count: repeaters_deleted_count }
  end

  OUTPUT = 0
  INPUT = 1
  CTCSS = 2
  CALL_SIGN = 3
  LOCATION = 4
  SPONSOR = 5
  STATUS = 6
  NOTES = 7
  STATION_TYPE = 8

  def import_repeater(row)
    call_sign = row[CALL_SIGN].text.strip.upcase
    puts call_sign
    tx_frequency = row[OUTPUT].text.to_f * 10 ** 6
    puts tx_frequency

    repeater = Repeater.find_or_initialize_by(call_sign: call_sign, tx_frequency: tx_frequency)

    # Only update repeaters that were sourced from this same source, or artscipub which we override, are considered.
    if repeater.persisted? && !(repeater.source == self.class.source ||
      repeater.source == ArtscipubImporter.source ||
      repeater.source == IrlpImporter.source)

      @logger.info "Not updating #{repeater} since the source is #{repeater.source.inspect}."
      return [:ignored_due_to_source, repeater]
    end

    repeater.name = repeater.call_sign

    repeater.rx_frequency = row[INPUT].text.to_f * 10 ** 6
    repeater.fm_ctcss_tone = row[CTCSS].text.to_f if row[CTCSS].text.strip.present?
    repeater.input_locality = row[LOCATION].text.strip
    repeater.input_region = "California"
    repeater.input_country_id = "us"

    repeater.source = self.class.source

    repeater.save!
    [:created_or_updated, repeater]
  rescue => e
    raise "Failed to save #{repeater.inspect} due to: #{e.message}"
  end

  def import_mode_access_code(repeater, access, notes)
    # When a repeater changes mode, the old modes that are no longer there shouldn't remain set to true.
    repeater.disable_all_modes

    access_codes = access.split("/")
    access_codes.each do |access_code|
      if access_code.to_d == BigDecimal("1750.0")
        repeater.fm = true
        repeater.fm_tone_burst = true
      elsif access_code.to_f.in? Repeater::CTCSS_TONES
        repeater.fm = true
        repeater.fm_ctcss_tone = access_code.to_f
      elsif access_code.to_d == 110 # Assuming it's a typo and should be 110.9.
        repeater.fm = true
        repeater.fm_ctcss_tone = 110.9
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
