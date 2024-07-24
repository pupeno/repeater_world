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

      repeaters_deleted_count = Repeater.where(source: self.class.source).where.not(id: created_or_updated_ids).destroy_all.count
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
    tx_frequency = row[OUTPUT].text.to_f * 10 ** 6

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

    repeater.notes = ""
    repeater.notes += "Sponsor: #{row[SPONSOR].text.strip}\n" if row[SPONSOR].text.strip.present?
    repeater.notes += "Status: #{row[STATUS].text.strip}\n" if row[STATUS].text.strip.present?
    repeater.notes += "Open station\n" if row[NOTES].text =~ /o/
    repeater.notes += "Closed station (see FCC 97.205, paragraph \"e\")\n" if row[NOTES].text =~ /c/
    repeater.notes += "Emergency power\n" if row[NOTES].text =~ /e/
    repeater.notes += "Linked\n" if row[NOTES].text =~ /l/
    repeater.notes += "Affiliated with RACES\n" if row[NOTES].text =~ /r/
    repeater.notes += "Affiliated with ARES\n" if row[NOTES].text =~ /s/
    repeater.notes += "Wide area coverage\n" if row[NOTES].text =~ /x/
    repeater.notes += "Station type: #{row[STATION_TYPE].text.strip}\n" if row[STATION_TYPE].text.strip.present?

    echo_link = row[NOTES].text.match(/E:(\d+)/)
    if echo_link.present?
      repeater.echo_link = true
      repeater.echo_link_node_number = echo_link[1]
    end

    repeater.source = self.class.source

    repeater.save!
    [:created_or_updated, repeater]
  rescue => e
    raise "Failed to save #{repeater.inspect} due to: #{e.message}"
  end
end
