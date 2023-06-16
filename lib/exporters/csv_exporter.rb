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

# Hopefully when we add more exporters, this class will get a better name.
class CsvExporter < Exporter
  def export
    columns = [
      :name, :call_sign, :web_site, :keeper, :band, :operational, :tx_frequency, :rx_frequency, :fm, :nfm,
      :fm_tone_burst, :fm_ctcss_tone, :fm_tone_squelch, :dstar, :dstar_port, :fusion, :dmr, :dmr_color_code,
      :dmr_network, :nxdn, :p25, :tetra, :latitude, :longitude, :grid_square, :address, :locality, :region,
      :post_code, :country_id, :tx_power, :tx_antenna, :tx_antenna_polarization, :rx_antenna,
      :rx_antenna_polarization, :altitude_asl, :altitude_agl, :bearing, :utc_offset, :channel, :notes, :source,
      :redistribution_limitations
    ]
    column_names = columns.each_with_object({}) do |column, columns|
      columns[column] = column.to_s.tr("_", " ").titleize
    end

    # Some columns require special cases.
    column_names[:fm] = "FM"
    column_names[:fm_tone_burst] = "Tone Burst"
    column_names[:fm_ctcss_tone] = "CTCSS Tone"
    column_names[:fm_tone_squelch] = "Tone Squelch"
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
