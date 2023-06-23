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

class ArtscipubImporter < Importer
  def self.source
    "http://www.artscipub.com/repeaters/"
  end

  private

  EXPORT_URL = "http://www.artscipub.com/repeaters/"

  def import_data
    ignored_due_to_source_count = 0
    created_or_updated_ids = []
    repeaters_deleted_count = 0

    home_file_name = download_file(EXPORT_URL, "home.html")
    home = Nokogiri::HTML(File.read(home_file_name), nil, "windows-1252")

    raw_repeaters = []

    home.search("a[href^=\"/repeaters/search/index.asp?state=\"]").each do |state_country_link|
      page = 1
      state_country_name = state_country_link.text.gsub(/^\./, "_")
      current_url = EXPORT_URL

      loop do
        current_url = URI.join(current_url, state_country_link["href"]).to_s
        list_file_name = download_file(current_url, "#{state_country_name}_#{page}.html")
        list_file = Nokogiri::HTML(File.read(list_file_name), nil, "windows-1252")

        list_file.search("a[href^=\"/repeaters/detail.asp?rid=\"]").each do |repeater_link|
          repeater_id = repeater_link["href"].match(/rid=(\d+)&/)[1]
          repeater_file_name = download_file(URI.join(current_url, URI::DEFAULT_PARSER.escape(repeater_link["href"])).to_s, "#{repeater_id}.html")
          repeater_file = Nokogiri::HTML(File.read(repeater_file_name), nil, "windows-1252")
          raw_repeaters << extract_raw_repeater(repeater_file)
        end

        # Next!
        state_country_link = list_file.at("a[text()=' Next ']")
        page += 1
        break if state_country_link.blank?
      end
    end

    # puts @mocks

    # TODO: replace Ø with 0.

    [ignored_due_to_source_count, created_or_updated_ids, repeaters_deleted_count]
  end

  def extract_raw_repeater(repeater_file)
    raw_repeater = {}

    # First find the table with the data.
    table = repeater_file.at_xpath("//td[normalize-space() = 'Repeater ID #']/ancestor::*[name()='table'][position() = 1]")

    raw_repeater[:external_id] = table.at_xpath("tr[td[normalize-space() = 'Repeater ID #']]/td[2]").text.match(/(\d+)/)[1] # There's other text in the external_id cell that we don't want.
    raw_repeater[:call_sign] = table.at_xpath("tr[td[normalize-space() = 'Call Sign']]/td[2]").text&.strip
    raw_repeater[:location] = table.at_xpath("tr[td[normalize-space() = 'Location']]/td[2]").text&.strip
    raw_repeater[:frequency] = table.at_xpath("tr[td[normalize-space() = 'Frequency']]/td[2]").text&.strip
    raw_repeater[:input] = table.at_xpath("tr[td[normalize-space() = 'Input']]/td[2]").text&.strip
    raw_repeater[:pl_tone] = table.at_xpath("tr[td[normalize-space() = 'PL Tone']]/td[2]").text&.strip
    raw_repeater[:rating] = table.at_xpath("tr[td[normalize-space() = 'Rating']]/td[2]").text&.strip
    raw_repeater[:auto_patch] = table.at_xpath("tr[td[normalize-space() = 'Auto Patch']]/td[2]").text&.strip
    raw_repeater[:web_site] = table.at_xpath("tr[td[normalize-space() = 'Web Site']]/td[2]").text&.strip
    raw_repeater[:grid_square] = table.at_xpath("tr[td[normalize-space() = 'Grid Square']]/td[2]").text&.strip
    raw_repeater[:zip_code] = table.at_xpath("tr[td[normalize-space() = 'Zip Code.']]/td[2]//b").text&.strip # This one is different, because there's some cruft in this cell.
    raw_repeater[:latitude] = table.at_xpath("tr[td[normalize-space() = 'Latitude']]/td[2]").text&.strip
    raw_repeater[:longitude] = table.at_xpath("tr[td[normalize-space() = 'Longitude']]/td[2]").text&.strip
    raw_repeater[:comments] = table.at_xpath("tr[td[normalize-space() = 'Comments']]/td[2]").text&.strip

    raw_repeater
  end

  def download_file(url, dest)
    @mocks ||= {}
    @mocks[url] = dest
    super
  end
end
