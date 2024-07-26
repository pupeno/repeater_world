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

  def import_repeater(raw_repeater)
    call_sign = raw_repeater["CallSign"]&.upcase
    if call_sign.blank? || call_sign == "*"
      @logger.info "Ignoring repeater since the call sign is #{raw_repeater["CallSign"]}"
      return [:ignored_due_to_broken_record, nil]
    elsif call_sign == "K5NX" && raw_repeater["Freq"] == "157.5600"
      @logger.info "Ignoring repeater since frequency is outside the band plan #{raw_repeater["CallSign"]}"
      return [:ignored_due_to_broken_record, nil]
    end

    tx_frequency = raw_repeater["Freq"].to_f.abs * 10**6 # Yes, there's a repeater with negative frequency.
    if call_sign == "W7NJN" && tx_frequency == 147_500_000_000 # Someone mixed their Mhz and khz
      tx_frequency = 147_500_000
    elsif call_sign == "W7UPS" && tx_frequency == 446_525_000_000 # Someone mixed their Mhz and khz
      tx_frequency = 446_525_000
    end
    if tx_frequency == 0
      @logger.info "Ignoring #{call_sign} since the frequency is 0"
      return [:ignored_due_to_broken_record, nil]
    end

    repeater = Repeater.find_or_initialize_by(call_sign: call_sign, tx_frequency: tx_frequency)

    repeater.rx_frequency = repeater.tx_frequency + raw_repeater["Offset"].to_f * 10**3 if repeater.rx_frequency.blank? || repeater.source == self.class.source
    repeater.fm = true # Just making an assumption here, we don't have access code, so this is actually a bit useless.

    repeater.input_locality = raw_repeater["City"] if repeater.input_locality.blank? || repeater.source == self.class.source
    repeater.input_country_id = parse_country(raw_repeater) if repeater.input_country_id.blank? || repeater.source == self.class.source
    if repeater.input_region.blank? || repeater.source == self.class.source
      repeater.input_region = if repeater.input_country_id == "us"
        figure_out_us_state(raw_repeater["Prov./St"])
      elsif repeater.input_country_id == "ca"
        figure_out_canadian_province(raw_repeater["Prov./St"])
      else
        raw_repeater["Prov./St"]
      end
    end

    latitude = to_f_or_nil(raw_repeater["lat"])
    longitude = to_f_or_nil(raw_repeater["long"])
    if latitude.present? && longitude.present? &&
        (latitude != 0 || longitude != 0) && # One should be different to 0, since 0,0 is used to represent lack of data and there are no repeaters in null island
        (latitude <= 90 && latitude >= -90) # There can't be latitudes above 90 or below -90, those are typos.
      repeater.input_latitude = latitude if repeater.input_latitude.blank? || repeater.source == self.class.source
      repeater.input_longitude = longitude if repeater.input_longitude.blank? || repeater.source == self.class.source
    end

    repeater.external_id = raw_repeater["Record"] if repeater.input_region.blank? || repeater.source == self.class.source
    repeater.irlp = true # In this case, IRLP is authoritative
    repeater.irlp_node_number = raw_repeater["Record"] # In this case, IRLP is authoritative
    repeater.keeper = raw_repeater["Owner"] if repeater.keeper.blank? || repeater.source == self.class.source
    repeater.web_site = raw_repeater["URL"] if repeater.web_site.blank? || repeater.source == self.class.source

    repeater.source ||= self.class.source
    repeater.save!

    [:created_or_updated, repeater]
  rescue => e
    raise "Failed to save #{repeater.inspect} due to: #{e.message}"
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
