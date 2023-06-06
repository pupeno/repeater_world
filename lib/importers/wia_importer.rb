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

class WiaImporter < Importer
  private

  EXPORT_URL = "https://www.wia.org.au/members/repeaters/data/"

  def import_data
    ignored_due_to_source_count = 0
    created_or_updated_ids = []
    repeaters_deleted_count = 0

    csv_file_name = get_csv_url
    csv_file = download_file(csv_file_name, "wia.csv")

    [ignored_due_to_source_count, created_or_updated_ids, repeaters_deleted_count]
  end

  # WIA seems to publish a different CSV file every quarter, so first we need to find the latest CSV file name.
  def get_csv_url
    wia_html_url = download_file(EXPORT_URL, "wia.html")
    html = File.open(wia_html_url).read
    doc = Nokogiri::HTML(html)
    link = doc.css('a[href$=".csv"]').first

    if link.blank?
      raise "Unable to find the repeater list CSV link on #{wia_html_url}."
    end

    URI.join(EXPORT_URL, link["href"].gsub(" ", "%20")).to_s # TODO: find a better way to achieve this that gsub.
  end

  def source
    "https://www.wia.org.au/members/repeaters/data/"
  end
end
