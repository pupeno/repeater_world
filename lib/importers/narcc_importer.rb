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
    "https://www.narcconline.org/narcc/Repeater_List_Menu.cfm?CZONE=All&SBAND=2000&SType=All&Status=All"
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
      local_file_name = "#{export_url.match(/SBAND=(\d+)/)[1]}.html"
      file_name = download_file(export_url, local_file_name)

      doc = Nokogiri::HTML(File.read(file_name))
      table = doc.at("table")
      table.search("tr").each_with_index do |row, index|
        row = row.search("td")
        next if row[1].nil? || row[0].text.strip == "Output" # Various header rows.

        yield(row, "#{local_file_name}:#{index}")
      end
    end
  end

  def call_sign_and_tx_frequency(raw_repeater)
    [raw_repeater[CALL_SIGN].text.strip.upcase,
      raw_repeater[OUTPUT].text.to_f * 10**6]
  end

  def import_repeater(raw_repeater, repeater)
    repeater.rx_frequency = raw_repeater[INPUT].text.to_f * 10**6
    repeater.fm = true # Odd, are they only FM? Surely there are other modes there.
    repeater.fm_ctcss_tone = raw_repeater[CTCSS].text.to_f if raw_repeater[CTCSS].text.strip.present?
    repeater.input_locality = raw_repeater[LOCATION].text.strip
    repeater.input_region = "California"
    repeater.input_country_id = "us"

    repeater.notes = ""
    repeater.notes += "Sponsor: #{raw_repeater[SPONSOR].text.strip}\n" if raw_repeater[SPONSOR].text.strip.present?
    repeater.notes += "Status: #{raw_repeater[STATUS].text.strip}\n" if raw_repeater[STATUS].text.strip.present?
    repeater.notes += "Open station\n" if /o/.match?(raw_repeater[NOTES].text)
    repeater.notes += "Closed station (see FCC 97.205, paragraph \"e\")\n" if /c/.match?(raw_repeater[NOTES].text)
    repeater.notes += "Emergency power\n" if /e/.match?(raw_repeater[NOTES].text)
    repeater.notes += "Linked\n" if /l/.match?(raw_repeater[NOTES].text)
    repeater.notes += "Affiliated with RACES\n" if /r/.match?(raw_repeater[NOTES].text)
    repeater.notes += "Affiliated with ARES\n" if /s/.match?(raw_repeater[NOTES].text)
    repeater.notes += "Wide area coverage\n" if /x/.match?(raw_repeater[NOTES].text)
    repeater.notes += "Station type: #{raw_repeater[STATION_TYPE].text.strip}\n" if raw_repeater[STATION_TYPE].text.strip.present?

    echo_link = raw_repeater[NOTES].text.match(/E:(\d+)/)
    if echo_link.present?
      repeater.echo_link = true
      repeater.echo_link_node_number = echo_link[1]
    end

    irlp_node_number = raw_repeater[NOTES].text.match(/I:(\d+)/)
    if irlp_node_number.present?
      repeater.irlp = true
      repeater.irlp_node_number ||= irlp_node_number[1] # IRLP's authoritative value comes from the IrlpImporter.
    end

    repeater.source = self.class.source

    repeater.save!
    repeater
  end
end
