# Hopefully when we add more exporters, this class will get a better name.
class CsvExporter < Exporter
  def export
    columns = [
      :name, :call_sign, :band, :channel, :keeper, :operational, :notes, :tx_frequency,
      :rx_frequency, :fm, :access_method, :ctcss_tone, :tone_sql, :dstar, :fusion, :dmr,
      :dmr_cc, :dmr_con, :nxdn, :latitude, :longitude, :grid_square, :country_id,
      :region_1, :region_2, :region_3, :region_4, :utc_offset, :source
    ]
    column_names = columns.each_with_object({}) do |column, columns|
      columns[column] = column.to_s.tr("_", " ").titleize
    end

    # Some columns require special cases.
    column_names[:fm] = "FM"
    column_names[:ctcss_tone] = "CTCSS Tone"
    column_names[:ctcss_sql] = "Tone SQL"
    column_names[:dstar] = "D-Star"
    column_names[:dmr] = "DMR"
    column_names[:dmr_cc] = "DMR CC"
    column_names[:dmr_con] = "DMR Con"
    column_names[:nxdn] = "NXDN"
    column_names[:utc_offset] = "UTC Offset"

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
