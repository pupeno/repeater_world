# Copyright 2023, Pablo Fernandez
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

class IrlpImporter < Importer
  def self.source
    "https://www.irlp.net"
  end

  private

  EXPORT_URL = "https://status.irlp.net/nohtmlstatus.txt.bz2"

  def import_data
    ignored_due_to_source_count = 0
    created_or_updated_ids = []
    repeaters_deleted_count = 0

    compressed_file_name = download_file(EXPORT_URL, "irlp.tsv.bz2")
    uncompressed_file = RBzip2.default_adapter::Decompressor.new(File.open(compressed_file_name))
    file_contents = uncompressed_file.read
    file_contents.gsub!("http://www.lcarc.ca/          TARGET=\"_blank\"", "http://www.lcarc.ca/") # Makes the CSV parser fail.
    tsv_file = CSV.parse(file_contents, col_sep: "\t", headers: true)

    Repeater.transaction do
      tsv_file.each_with_index do |raw_repeater, line_number|
        action, imported_repeater = import_repeater(raw_repeater)
        if action == :ignored_due_to_source
          ignored_due_to_source_count += 1
        elsif action == :ignored_due_to_broken_record
          # Nothing to do really. Should we track this?
        else
          created_or_updated_ids << imported_repeater.id
        end
      rescue
        raise "Failed to import record on line #{line_number + 2}: #{raw_repeater}" # Line numbers start at 1, not 0, and there's a header, hence the +2
      end
      repeaters_deleted_count = Repeater.where(source: self.class.source).where.not(id: created_or_updated_ids).delete_all
    end

    [ignored_due_to_source_count, created_or_updated_ids, repeaters_deleted_count]
  end

  COUNTRY_CODES = {
    "Anguilla" => "ai",
    "Antigua & Barbuda" => "ag",
    "Australia" => "au",
    "Barbados" => "bb",
    "Bermuda" => "bm",
    "Canada" => "ca",
    "Canary Islands" => "es",
    "Denmark" => "dk",
    "Dominica" => "dm",
    "Ecuador" => "ec",
    "England" => "gb",
    "Germany" => "de",
    "Ireland" => "ie",
    "Italy" => "it",
    "Jamaica" => "jm",
    "Japan" => "jp",
    "Mexico" => "mx",
    "Montserrat" => "ms",
    "Netherlands" => "nl",
    "New Zealand" => "nz",
    "Philippines" => "ph",
    "Saint Kitts & Nevis" => "kn",
    "Scotland" => "gb",
    "Spain" => "es",
    "Sweden" => "se",
    "USA" => "us",
    "Virgin Islands, United States" => "vi"
  }

  def import_repeater(raw_repeater)
    call_sign = raw_repeater["CallSign"].upcase
    if call_sign.blank? || call_sign == "*"
      @logger.info "Ignoring repeater since the call sign is #{raw_repeater["CallSign"]}"
      return [:ignored_due_to_broken_record, nil]
    end
    tx_frequency = raw_repeater["Freq"].to_f.abs * 10**6 # Yes, there's a repeater with negative frequency.
    if tx_frequency == 0
      @logger.info "Ignoring #{call_sign} since the frequency is 0"
      return [:ignored_due_to_broken_record, nil]
    end
    repeater = Repeater.find_or_initialize_by(call_sign: call_sign, tx_frequency: tx_frequency)

    # Only update repeaters that were sourced from this same source.
    if repeater.persisted? && repeater.source != self.class.source
      @logger.info "Not updating #{repeater} since the source is #{repeater.source.inspect} and not #{self.class.source.inspect}"
      return [:ignored_due_to_source, repeater]
    end

    repeater.rx_frequency = repeater.tx_frequency + raw_repeater["Offset"].to_f * 10**3
    if repeater.tx_frequency > 150_000_000 && repeater.tx_frequency < 160_000_000
      repeater.band = Repeater::BAND_2M # There's one repeater with frequency 157.56MHz, which is outside the band plan.
    end
    repeater.fm = true # Just making an assumption here, we don't have access code, so this is actually a bit useless.

    repeater.locality = raw_repeater["City"]
    repeater.region = raw_repeater["Prov./St"]
    repeater.country_id = COUNTRY_CODES[raw_repeater["Country"]] || raise("Unknown country: #{raw_repeater["Country"]}")
    repeater.latitude = raw_repeater["lat"].to_f unless raw_repeater["lat"].blank? || raw_repeater["lat"] == "0"
    repeater.longitude = raw_repeater["long"].to_f unless raw_repeater["long"].blank? || raw_repeater["long"] == "0"

    repeater.external_id = raw_repeater["Record"]
    repeater.keeper = raw_repeater["Owner"]
    repeater.web_site = raw_repeater["URL"]

    repeater.source = self.class.source
    repeater.save!

    [:created_or_updated, repeater]
  end
end

1_687_223_323
