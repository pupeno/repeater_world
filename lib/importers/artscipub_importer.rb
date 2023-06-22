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
    home = Nokogiri::HTML(File.read(home_file_name))

    home.search("a[href^=\"/repeaters/search/index.asp?state=\"]").each do |state_country_link|
      page = 1
      state_country_name = state_country_link.text.gsub(/^\./, "_")
      current_url = EXPORT_URL
      begin
        current_url = URI.join(current_url, state_country_link["href"]).to_s
        list_file_name = download_file(current_url, "#{state_country_name}_#{page}.html")
        puts list_file_name
        list = Nokogiri::HTML(File.read(list_file_name))
        state_country_link = list.at("a[text()=' Next ']")
        puts "state_country_link.inspect: #{state_country_link.inspect}"

        page += 1
      end while state_country_link.present?
    end

    # puts @mocks

    [ignored_due_to_source_count, created_or_updated_ids, repeaters_deleted_count]
  end

  def download_file(url, dest)
    @mocks ||= {}
    @mocks[url] = dest
    super
  end
end
