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

class WiaImporter < Importer
  def self.source
    "https://www.wia.org.au/members/repeaters/data/"
  end

  private

  EXPORT_URL = "https://www.wia.org.au/members/repeaters/data/"

  def import_all_repeaters
    csv_url = get_csv_url
    csv_file_name = download_file(csv_url, "wia.csv")
    csv_file = CSV.table(csv_file_name, headers: true)

    # TODO: this code is duplicated in nerepeaters_importer.rb.
    csv_file.each_with_index do |raw_repeater, line_number|
      if raw_repeater[:output].blank? # The CSV has sections separated by blank lines.
        @ignored_due_to_invalid_count += 1
        next
      end
      yield(raw_repeater, line_number)
    end
  end

  def call_sign_and_tx_frequency(raw_repeater)
    [raw_repeater[:call].upcase,
      raw_repeater[:output].to_f * 10**6]
  end

  def import_repeater(raw_repeater, repeater)
    repeater.band = RepeaterUtils.band_for_frequency(repeater.tx_frequency)
    repeater.rx_frequency = raw_repeater[:input].to_f * 10**6
    if !RepeaterUtils.is_frequency_in_band?(repeater.rx_frequency, repeater.band)
      repeater.cross_band = true
    end

    repeater.name = raw_repeater[:mnemonic] if raw_repeater[:mnemonic].present? && raw_repeater[:mnemonic].strip != "-"
    repeater.name ||= "#{raw_repeater[:location]} #{raw_repeater[:call]}"

    repeater.tx_power = raw_repeater[:erp] if raw_repeater[:erp].is_a? Numeric
    repeater.fm = true # Massive assumption here, since it's not part of the data.
    repeater.fm_ctcss_tone = raw_repeater[:tone] if raw_repeater[:tone].is_a? Numeric

    repeater.input_locality = raw_repeater[:location]
    repeater.input_region = raw_repeater[:service_area]
    if raw_repeater[:latitude].is_a?(Numeric) && raw_repeater[:longitude].is_a?(Numeric)
      repeater.input_latitude = raw_repeater[:latitude]
      repeater.input_longitude = raw_repeater[:longitude]
    end
    repeater.altitude_asl = raw_repeater[:hasl] if raw_repeater[:hasl].is_a? Numeric

    # According to https://www.wia.org.au/members/repeaters/data/documents/Repeater%20Directory%20230304.pdf
    # Statuses are:
    # O: Operating
    # T: Testing
    # P: Proposed
    # X: Currently off Air
    # U: License Pending
    repeater.operational = raw_repeater[:s] == "O"

    notes = []
    note_numbers = [raw_repeater[:notes], raw_repeater[15]].compact.join(", ") # They used comas to separate notes in the CSV, so they ended up as different columns.
    if note_numbers.present?
      notes << "#{note_numbers} in #{get_pdf_url}"
    end
    notes << case raw_repeater[:s]
    when "T"
      "Status: Testing"
    when "P"
      "Status: Proposed"
    when "X"
      "Status: Currently off Air"
    when "U"
      "Status: License Pending"
    end
    notes << "Timeout: #{raw_repeater[:to]}" if raw_repeater[:to].is_a? Numeric
    repeater.notes = notes.compact.join("\n")

    repeater.input_country_id = "au"
    repeater.source = self.class.source
    repeater.save!

    repeater
  end

  # WIA seems to publish a different CSV file every quarter, so first we need to find the latest CSV file name.
  def get_csv_url
    wia_html_url = download_file(EXPORT_URL, "wia.html")
    html = File.read(wia_html_url)
    doc = Nokogiri::HTML(html)
    link = doc.css('a[href$=".csv"]').first

    if link.blank?
      raise "Unable to find the repeater list CSV link on #{wia_html_url}."
    end

    URI.join(EXPORT_URL, link["href"].gsub(" ", "%20")).to_s # TODO: find a better way to achieve this that gsub.
  end

  def get_pdf_url
    if @pdf_url.blank?
      wia_html_url = download_file(EXPORT_URL, "wia.html")
      html = File.read(wia_html_url)
      doc = Nokogiri::HTML(html)
      link = doc.css('a[href$=".pdf"]').first

      if link.blank?
        raise "Unable to find the repeater list PDF link on #{wia_html_url}."
      end

      @pdf_url = URI.join(EXPORT_URL, link["href"].gsub(" ", "%20")).to_s # TODO: find a better way to achieve this that gsub.
    end
    @pdf_url
  end
end
