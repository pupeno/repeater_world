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

class IrtsImporter < Importer
  def self.source
    "https://www.irts.ie/cgi/repeater.cgi"
  end

  private

  EXPORT_URL = "https://www.irts.ie/cgi/repeater.cgi?printable"

  def import_data
    ignored_due_to_source_count = 0
    created_or_updated_ids = []
    repeaters_deleted_count = 0

    file_name = download_file(EXPORT_URL, "irts.html")

    doc = Nokogiri::HTML(File.read(file_name))
    table = doc.at("table")

    Repeater.transaction do
      table.search("tr").each do |row|
        row = row.search("td")
        next if row.empty?

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

      repeaters_deleted_count = Repeater.where(source: self.class.source).where.not(id: created_or_updated_ids).delete_all
    end

    {created_or_updated_ids: created_or_updated_ids,
     ignored_due_to_source_count: ignored_due_to_source_count,
     ignored_due_to_invalid_count: 0,
     repeaters_deleted_count: repeaters_deleted_count}
  end

  CHANNEL = 0
  FREQUENCY = 1
  CALL_SIGN = 2
  ACCESS = 3
  LOCATION = 4
  NOTES = 5

  FREQUENCY_REGEX = /Output:[^\d]+([\d.]+)Input:[^\d]+([\d.]+)/

  def import_repeater(row)
    call_sign = row[CALL_SIGN].text.strip.upcase

    if call_sign.start_with? "GB"
      return [:ignored_due_to_broken_record, nil] # GB repeaters are being imported from UKRepeater.net.
    end

    tx_frequency = row[FREQUENCY].text.scan(FREQUENCY_REGEX).flatten.first.to_f * 10**6

    repeater = Repeater.find_or_initialize_by(call_sign: call_sign, tx_frequency: tx_frequency)

    # Only update repeaters that were sourced from this same source.
    if repeater.persisted? && repeater.source != self.class.source && repeater.source != IrlpImporter.source
      @logger.info "Not updating #{repeater} since the source is #{repeater.source.inspect} and not #{self.class.source.inspect}"
      return [:ignored_due_to_source, repeater]
    end
    repeater.name = repeater.call_sign

    repeater.channel = row[CHANNEL].text.strip
    repeater.rx_frequency = row[FREQUENCY].text.scan(FREQUENCY_REGEX).flatten.second.to_f * 10**6
    import_mode_access_code(repeater, row[ACCESS].text.strip, row[NOTES].text.strip)
    import_location(repeater, row[LOCATION])
    repeater.notes = row[NOTES].text.strip

    repeater.country_id = "ie"
    repeater.source = self.class.source

    repeater.save!
    [:created_or_updated, repeater]
  rescue => e
    raise "Failed to save #{repeater.inspect} due to: #{e.message}"
  end

  def import_mode_access_code(repeater, access, notes)
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

    repeater.grid_square = location.last

    address = location[0..-2].join(",")
    address = address.split(",").map { |x| x.strip.gsub(/\s+/, " ").tr("\u00A0", " ") }

    if address.size == 1
      if address[0].start_with? "Co"
        repeater.locality = nil
        repeater.region = address.first
      else
        repeater.locality = address.first
        repeater.region = nil
      end
    else
      repeater.locality = address[0..-2].join(",")
      repeater.region = address[-1]
    end
  end
end
