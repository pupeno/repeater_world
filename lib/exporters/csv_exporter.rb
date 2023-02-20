# Copyright 2023, Flexpoint Tech
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Foobar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with Foobar. If not, see
# <https://www.gnu.org/licenses/>.

# Hopefully when we add more exporters, this class will get a better name.
class CsvExporter < Exporter
  def export
    columns = [
      :name, :call_sign, :band, :channel, :keeper, :operational, :notes, :tx_frequency, :rx_frequency, :fm,
      :access_method, :ctcss_tone, :tone_sql, :dstar, :fusion, :dmr, :dmr_color_code, :dmr_network, :nxdn, :latitude,
      :longitude, :grid_square, :address, :locality, :region, :post_code, :country_id, :utc_offset, :source,
      :redistribution_limitations
    ]
    column_names = columns.each_with_object({}) do |column, columns|
      columns[column] = column.to_s.tr("_", " ").titleize
    end

    # Some columns require special cases.
    column_names[:fm] = "FM"
    column_names[:ctcss_tone] = "CTCSS Tone"
    column_names[:tone_sql] = "Tone SQL"
    column_names[:dstar] = "D-Star"
    column_names[:dmr] = "DMR"
    column_names[:dmr_color_code] = "DMR Color Code"
    column_names[:dmr_network] = "DMR Network"
    column_names[:nxdn] = "NXDN"
    column_names[:utc_offset] = "UTC Offset"
    column_names[:redistribution_limitations] = "Redistribution Limitations"

    CSV.generate(headers: columns.map { |c| column_names[c] }, write_headers: true) do |csv|
      @repeaters.each do |repeater|
        csv << columns.each_with_object({}) do |column, line|
          line[column_names[column]] = case column
          when :latitude
            repeater.latitude
          when :longitude
            repeater.longitude
          else
            repeater.send(column)
          end
        end
      end
    end
  end
end
