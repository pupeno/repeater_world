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

class IrlpImporter < Importer
  def self.source
    "https://www.irlp.net"
  end

  private

  EXPORT_URL = "https://status.irlp.net/nohtmlstatus.txt.bz2"

  def import_all_repeaters
    compressed_file_name = download_file(EXPORT_URL, "irlp.tsv.bz2")
    uncompressed_file = RBzip2.default_adapter::Decompressor.new(File.open(compressed_file_name))
    file_contents = uncompressed_file.read.force_encoding("utf-8")
    file_contents.gsub!("http://www.lcarc.ca/          TARGET=\"_blank\"", "http://www.lcarc.ca/") # Makes the CSV parser fail.
    tsv_file = CSV.parse(file_contents, col_sep: "\t", headers: true)

    tsv_file.each_with_index do |raw_repeater, line_number|
      yield(raw_repeater, line_number + 2) # Line numbers start at 1, not 0, and there's a header, hence the +2
    end
  end

  def call_sign_and_tx_frequency(raw_repeater)
    call_sign = raw_repeater["CallSign"].upcase
    if call_sign.blank? || call_sign == "*"
      @ignored_due_to_invalid_count += 1
      return nil
    elsif call_sign == "K5NX" && raw_repeater["Freq"] == "157.5600"
      @ignored_due_to_invalid_count += 1
      return nil
    end

    tx_frequency = raw_repeater["Freq"].to_f.abs * 10**6 # Yes, there's a repeater with negative frequency.
    if call_sign == "W7NJN" && tx_frequency == 147_500_000_000 # Someone mixed their Mhz and khz
      tx_frequency = 147_500_000
    elsif call_sign == "W7UPS" && tx_frequency == 446_525_000_000 # Someone mixed their Mhz and khz
      tx_frequency = 446_525_000
    end
    if tx_frequency == 0
      @ignored_due_to_invalid_count += 1
      return nil
    end
    [call_sign, tx_frequency]
  end

  def import_repeater(raw_repeater, repeater)
    repeater.irlp = true # In this case, IRLP is authoritative
    repeater.irlp_node_number = raw_repeater["Record"] # In this case, IRLP is authoritative

    # If the source is not IrlpImporter, we keep importing the IRLP node number from this importer, but nothing else.
    if repeater.persisted? && repeater.source != self.class.source
      repeater.save!
      return repeater
    end

    repeater.band = RepeaterUtils.band_for_frequency(repeater.tx_frequency)
    repeater.rx_frequency = repeater.tx_frequency + raw_repeater["Offset"].to_f * 10**3
    if !RepeaterUtils.is_frequency_in_band?(repeater.rx_frequency, repeater.band)
      repeater.cross_band = true
    end
    repeater.fm = true # Just making an assumption here, we don't have access code, so this is actually a bit useless.

    repeater.input_locality = raw_repeater["City"]
    repeater.input_country_id = parse_country(raw_repeater)
    repeater.input_region = if repeater.input_country_id == "us"
      figure_out_us_state(raw_repeater["Prov./St"])
    elsif repeater.input_country_id == "ca"
      if repeater.call_sign == "VA6MEX" && raw_repeater["Prov./St"] == "ED"
        "Alberta" # ED is not a province, but Edmonton is the capital of Alberta.
      else
        figure_out_canadian_province(raw_repeater["Prov./St"])
      end
    else
      raw_repeater["Prov./St"]
    end

    latitude = to_f_or_nil(raw_repeater["lat"])
    longitude = to_f_or_nil(raw_repeater["long"])
    if latitude.present? && longitude.present? &&
        (latitude != 0 || longitude != 0) && # One should be different to 0, since 0,0 is used to represent lack of data and there are no repeaters in null island
        (latitude <= 90 && latitude >= -90) # There can't be latitudes above 90 or below -90, those are typos.
      repeater.input_latitude = latitude
      repeater.input_longitude = longitude
    end

    repeater.external_id = raw_repeater["Record"]
    repeater.keeper = raw_repeater["Owner"]
    repeater.web_site = raw_repeater["URL"]

    repeater.source ||= self.class.source
    repeater.save!

    repeater
  end

  def parse_country(raw_repeater)
    non_countries = {
      "Antigua & Barbuda" => "ag",
      "Canary Islands" => "es",
      "Saint Kitts & Nevis" => "kn",
      "Scotland" => "gb",
      "Virgin Islands, United States" => "vi"
    }
    country = ISO3166::Country.find_country_by_any_name(raw_repeater["Country"])
    if country.present?
      country.alpha2.downcase
    elsif raw_repeater["Country"] == "Netherlands Antilles"
      # Netherlands Antilles stopped existing in 2010 and turned into several different countries so there can't be a
      # one to one mapping and we have to go repeater by repeater.
      if raw_repeater["CallSign"] == "PJ7R" # This repeater is actually in "Sint Maarten".
        "sx"
      else
        raise "The country Netherlands Antilles doesn't exist anymore."
      end
    else
      non_countries[raw_repeater["Country"]] || raise("Unknown country: #{raw_repeater["Country"]}")
    end
  end

  def to_f_or_nil(value)
    Float(value)
  rescue TypeError, ArgumentError
    nil
  end
end
