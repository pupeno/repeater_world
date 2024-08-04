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

# Hopefully when we add more exporters, this class will get a better name.
class CsvExporter < Exporter
  def export
    headers = Repeater::EXPORTABLE_ATTRIBUTES.map { |c| Repeater.human_attribute_name(c) }
    CSV.generate(headers: headers, write_headers: true, encoding: Encoding::UTF_8) do |csv|
      @results.each do |result|
        repeater = result.searchable
        csv << Repeater::EXPORTABLE_ATTRIBUTES.each_with_object({}) do |column, line|
          line[Repeater.human_attribute_name(column)] = repeater.send(column)
        end
      end
    end
  end
end
