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

    raw_repeaters = get_raw_repeaters

    Repeater.transaction do
      raw_repeaters.each do |raw_repeater|
        action, imported_repeater = import_repeater(raw_repeater)
        if action == :ignored_due_to_source
          ignored_due_to_source_count += 1
        elsif action == :ignored_due_to_broken_record
          # Nothing to do really. Should we track this?
        else
          created_or_updated_ids << imported_repeater.id
        end
      rescue
        raise "Failed to import record on #{raw_repeater}"
      end

      repeaters_deleted_count = Repeater.where(source: self.class.source).where.not(id: created_or_updated_ids).delete_all
    end

    # puts @mocks

    [ignored_due_to_source_count, created_or_updated_ids, repeaters_deleted_count]
  end

  def get_raw_repeaters
    raw_repeaters_file_name = File.join(@working_directory, "raw_repeaters")

    raw_repeaters = []

    if !File.exist?(raw_repeaters_file_name)
      home_file_name = download_file(EXPORT_URL, "home.html")
      home = Nokogiri::HTML(File.read(home_file_name), nil, "windows-1252")
      home.search("a[href^=\"/repeaters/search/index.asp?state=\"]").each do |state_country_link|
        page = 1
        state_country_name = state_country_link.text.gsub(/^\./, "_")
        current_url = EXPORT_URL

        loop do
          current_url = URI.join(current_url, state_country_link["href"]).to_s
          list_file_name = download_file(current_url, "#{state_country_name}_#{page}.html")
          list_file = Nokogiri::HTML(File.read(list_file_name), nil, "windows-1252")

          list_file.search("a[href^=\"/repeaters/detail.asp?rid=\"]").each do |repeater_link|
            repeater_id = repeater_link["href"].match(/rid=(\d+)&/)[1]
            repeater_web_page = URI.join(current_url, URI::DEFAULT_PARSER.escape(repeater_link["href"])).to_s
            repeater_file_name = download_file(repeater_web_page, "#{repeater_id}.html")
            repeater_file = Nokogiri::HTML(File.read(repeater_file_name), nil, "windows-1252")
            raw_repeater = extract_raw_repeater(repeater_file)
            raw_repeater[:original_record_page] = repeater_web_page
            raw_repeaters << raw_repeater
          end

          # Next!
          state_country_link = list_file.at("a[text()=' Next ']")
          page += 1
          break if state_country_link.blank?
        end
      end
      # File.write(raw_repeaters_file_name, JSON.generate(raw_repeaters))
      File.open(raw_repeaters_file_name, 'wb') do |file|
        file.write(Marshal.dump(raw_repeaters))
      end

    else
      @logger.info "Skipping reading the files because #{raw_repeaters_file_name} is present."
      raw_repeaters = File.open(raw_repeaters_file_name, "rb") do |file|
        Marshal.load(file.read)
      end
    end

    raw_repeaters
  end

  def extract_raw_repeater(repeater_file)
    raw_repeater = {}

    # First find the table with the data.
    table = repeater_file.at_xpath("//td[normalize-space() = 'Repeater ID #']/ancestor::*[name()='table'][position() = 1]")

    raw_repeater[:external_id] = table.at_xpath("tr[td[normalize-space() = 'Repeater ID #']]/td[2]").text.match(/(\d+)/)[1] # There's other text in the external_id cell that we don't want.
    raw_repeater[:call_sign] = table.at_xpath("tr[td[normalize-space() = 'Call Sign']]/td[2]").text&.strip
    raw_repeater[:location] = table.at_xpath("tr[td[normalize-space() = 'Location']]/td[2]").text&.strip
    raw_repeater[:frequency] = table.at_xpath("tr[td[normalize-space() = 'Frequency']]/td[2]").text&.strip
    raw_repeater[:input] = table.at_xpath("tr[td[normalize-space() = 'Input']]/td[2]").text&.strip
    raw_repeater[:pl_tone] = table.at_xpath("tr[td[normalize-space() = 'PL Tone']]/td[2]").text&.strip
    raw_repeater[:rating] = table.at_xpath("tr[td[normalize-space() = 'Rating']]/td[2]").text&.strip
    raw_repeater[:auto_patch] = table.at_xpath("tr[td[normalize-space() = 'Auto Patch']]/td[2]").text&.strip
    raw_repeater[:web_site] = table.at_xpath("tr[td[normalize-space() = 'Web Site']]/td[2]").text&.strip
    raw_repeater[:grid_square] = table.at_xpath("tr[td[normalize-space() = 'Grid Square']]/td[2]").text&.strip
    raw_repeater[:zip_code] = table.at_xpath("tr[td[normalize-space() = 'Zip Code.']]/td[2]//b").text&.strip # This one is different, because there's some cruft in this cell.
    raw_repeater[:latitude] = table.at_xpath("tr[td[normalize-space() = 'Latitude']]/td[2]").text&.strip
    raw_repeater[:longitude] = table.at_xpath("tr[td[normalize-space() = 'Longitude']]/td[2]").text&.strip
    raw_repeater[:comments] = table.at_xpath("tr[td[normalize-space() = 'Comments']]/td[2]").text&.strip

    raw_repeater
  end

  def import_repeater(raw_repeater)
    if raw_repeater[:comments]&.downcase&.include?("noaa") || # Not importing NOAA weather stations. Should we?
      raw_repeater[:web_site]&.downcase&.include?("noaa") || # Not importing NOAA weather stations. Should we?
      raw_repeater[:web_site]&.downcase&.include?("weather.gov") || # Not importing NOAA weather stations. Should we?
      raw_repeater[:call_sign].blank? || # Can't import a repeater without a call sign.
      raw_repeater[:frequency].blank? || raw_repeater[:frequency].to_f < 1 || # Can't import a repeater without a frequency.
      raw_repeater[:call_sign] =~ /[a-zA-Z]{3,4}[\-\s]?\d{3,4}/ || # Only interested in ham radio, not GMRS: https://github.com/flexpointtech/repeater_world/issues/264
      raw_repeater[:comments]&.downcase&.include?("gmrs") || # Only interested in ham radio, not GMRS: https://github.com/flexpointtech/repeater_world/issues/264
      raw_repeater[:web_site]&.downcase&.include?("gmrs") || # Only interested in ham radio, not GMRS: https://github.com/flexpointtech/repeater_world/issues/264
      raw_repeater[:call_sign] == "k6yo" || # Frequency out of band plan, comment is Private Repeater. DMR
      # raw_repeater[:call_sign] == "kan654" || # Frequency out of band plan, odd call sign.
      # raw_repeater[:call_sign] == "KAA 494" || # Frequency out of band plan, odd call sign.
      # raw_repeater[:call_sign] == "KAE0182" || # Frequency out of band plan, odd call sign.
      (raw_repeater[:call_sign] == "W0OES" && raw_repeater[:frequency] == "462.675+") || # Frequency out of band plan.
      (raw_repeater[:call_sign] == "W7YB" && raw_repeater[:frequency] == "148.88-") || # Frequency out of band plan.
      (raw_repeater[:call_sign] == "N4GSM" && raw_repeater[:frequency] == "154.110-") || # Frequency out of band plan.
      (raw_repeater[:call_sign] == "WX4CTC" && raw_repeater[:frequency] == "467.5875+") || # Frequency out of band plan.
      (raw_repeater[:call_sign] == "K1KYI" && raw_repeater[:frequency] == "149.94-") || # Frequency out of band plan.
      (raw_repeater[:call_sign] == "k5pc" && raw_repeater[:frequency] == "162.620-") || # Frequency out of band plan.
      (raw_repeater[:call_sign] == "xe2lmc" && raw_repeater[:frequency] == "148.880-") || # Frequency out of band plan.
      raw_repeater[:call_sign] == "koni" || # Frequency out of band plan, odd call sign.
      raw_repeater[:call_sign] == "USCG Aux" || # Frequency out of band plan, odd call sign.
      raw_repeater[:call_sign] == "WXL-51" || # What is this even?
      raw_repeater[:call_sign] == "unknown" || # Frequency out of band plan, not a call sign.
      raw_repeater[:call_sign] == "private" || # Frequency out of band plan, not a call sign.
      raw_repeater[:call_sign] == "General" || # Frequency out of band plan, not a call sign.
      raw_repeater[:call_sign] == "154.445" # Not a valid call sign, data entry error.
      # @logger.info "Not importing because of data issues: #{raw_repeater}"
      return [:ignored_due_to_broken_record, nil]
    end

    if raw_repeater[:call_sign] == "W6SAR" && raw_repeater[:frequency] == "164.640-" # Typo in the freq.
      raw_repeater[:frequency] = "146.640-"
    elsif raw_repeater[:call_sign] == "N1KGN" && raw_repeater[:frequency] == "141.7+" # Typo in the freq.
      raw_repeater[:frequency] = "441.7+"
    elsif raw_repeater[:call_sign] == "W4MOT" && raw_repeater[:frequency] == "149.790-" # Typo in the freq.
      raw_repeater[:frequency] = "147.105+"
    end

    call_sign = raw_repeater[:call_sign].tr("Ø", "0").upcase
    tx_frequency = raw_repeater[:frequency].to_f * 10 ** 6
    repeater = Repeater.find_or_initialize_by(call_sign: call_sign, tx_frequency: tx_frequency)

    # Only update repeaters that were sourced from this same source.
    if repeater.persisted? && repeater.source != self.class.source && repeater.source != IrlpImporter.source
      @logger.info "Not updating #{repeater} since the source is #{repeater.source.inspect} and not #{self.class.source.inspect}"
      return [:ignored_due_to_source, repeater]
    end

    repeater.external_id = raw_repeater[:external_id]

    import_rx_frequency(raw_repeater, repeater)

    import_country_region_post_code_locality(repeater, raw_repeater)
    repeater.grid_square = raw_repeater[:grid_square] if raw_repeater[:grid_square].present?
    if raw_repeater[:latitude].present? && raw_repeater[:longitude].present?
      repeater.latitude = raw_repeater[:latitude]
      repeater.longitude = raw_repeater[:longitude]
    end

    repeater.source = self.class.source
    repeater.save!

    [:created_or_updated, repeater]
  end

  def import_rx_frequency(raw_repeater, repeater)
    if raw_repeater[:input].present?
      repeater.rx_frequency = raw_repeater[:input].to_f * 10 ** 6
    else
      repeater.ensure_fields_are_set
      repeater.rx_frequency = if repeater.band == Repeater::BAND_10M && raw_repeater[:frequency].last == "+"
                                repeater.tx_frequency + 100_000 # This one might not exist.
                              elsif repeater.band == Repeater::BAND_10M && raw_repeater[:frequency].last == "-"
                                repeater.tx_frequency - 100_000
                              elsif repeater.band == Repeater::BAND_2M && raw_repeater[:frequency].last == "+"
                                repeater.tx_frequency + 600_000
                              elsif repeater.band == Repeater::BAND_2M && raw_repeater[:frequency].last == "-"
                                repeater.tx_frequency + 600_000
                              elsif repeater.band == Repeater::BAND_1_25M && raw_repeater[:frequency].last == "+"
                                repeater.tx_frequency - 1_600_000
                              elsif repeater.band == Repeater::BAND_1_25M && raw_repeater[:frequency].last == "-"
                                repeater.tx_frequency + 1_600_000
                              elsif repeater.band == Repeater::BAND_70CM && raw_repeater[:frequency].last == "+"
                                repeater.tx_frequency + 5_000_000
                              elsif repeater.band == Repeater::BAND_70CM && raw_repeater[:frequency].last == "-"
                                repeater.tx_frequency - 5_000_000
                              else
                                repeater.tx_frequency # There's at least one IRLP node without an input frequency. I think I need to improve my understanding of IRLP.
                                # raise "Couldn't figure out rx frequency for tx frequency #{raw_repeater[:frequency]} in band #{repeater.band} in #{raw_repeater}"
                              end
    end
  end

  def import_country_region_post_code_locality(repeater, raw_repeater)
    location = raw_repeater[:location].split(",").map(&:strip).reject(&:empty?)

    if location.last.start_with?(".") # This is how non US locations are formatted.
      repeater.country_id = figure_out_country(location)

      case repeater.country_id
      when "ca"
        repeater.region = figure_out_canadian_province(location)
        repeater.locality = location[0..-2].join(", ")
      when "gb"
        case location.last
        when ".England"
          repeater.locality = location[0..-2].join(", ")
          repeater.region = "England"
        when ".Norfolk-England"
          repeater.locality = location[0..-2].join(", ")
          repeater.region = "England"
          # when ".Scotland" # Not actually imported since we already have them, likely from ukrepeaters.
        else
          raise "Unknown UK location: #{location.inspect}"
        end
      when "in"
        case location.last
        when ".india"
          repeater.region = location[0..-2].join(", ")
        when ".Tamilnadu", ".TAMILNADU"
          repeater.locality = location[0..-2].join(", ")
          repeater.region = "Tamil Nadu"
        when ".TANIL NADU INDIA"
          repeater.locality = location[0..-2].join(", ")
          repeater.region = "Tamil Nadu"
        end
      else
        if location.length == 2 # Second is the country.
          repeater.region = location.first
        elsif location.length == 3 # Third is the country.
          repeater.locality = location.first
          repeater.region = location.second
        else
          raise "Unknown amount of location parts: #{location.inspect}"
        end
      end
    else
      repeater.country_id = "us"
      repeater.locality = location[0..-2].join(", ")
      repeater.region = location.last
      repeater.post_code = raw_repeater[:zip_code] if raw_repeater[:zip_code].present? && raw_repeater[:zip_code] != "00000"
    end
  end

  def figure_out_country(location)
    case location.last
    when ".AMERICAN SAMOA"
      "as"
    when ".Belgium"
      "be"
    when ".Brazil"
      "br"
    when ".Canada-Alberta", ".Canada-British Columbia", ".Canada-Manitoba", ".Canada-Newfoundland", ".Canada-Northwest Territories", ".Canada-Nova Scotia", ".Canada-Nunavut", ".Canada-Ontario", ".Canada-Quebec", ".Canada-Saskatchewan"
      "ca"
    when ".Dominican Republic"
      "do"
    when ".England", ".Scotland", ".Norfolk-England"
      "gb"
    when ".Germany"
      "de"
    when ".GUAM"
      "gu"
    when ".india", ".Tamilnadu", ".TAMILNADU", ".TANIL NADU INDIA"
      "in"
    when ".Indonesia"
      "id"
    when ".Japan"
      "jp"
    when ".Mexico", ".mexico", ".Baja California", ".Sinaloa", ".Sonora"
      "mx"
    when ".Netherlands"
      "nl"
    when ".Saipan" # ".NORTHERN-MARIANAS"
      "mp"
    when ".Poland"
      "pl"
    when ".Puerto Rico"
      "pr"
    when ".South Africa"
      "za"
    when ".South America" # Really??? _sigh_
      case location
      when ["Barrancabermeja (S.S)", ".South America"]
        "co"
      when ["Caracas", ".South America"]
        "ve"
      else
        raise "Don't know which South American country is #{location}"
      end
    when ".St. Martin"
      "mf"
    when ".Virgin Islands"
      "vi"
    else
      raise "Unknown country #{location.last} in location #{location}"
    end
  end

  def figure_out_canadian_province(location)
    case location.last
    when ".Canada-Alberta"
      "Alberta"
    when ".Canada-British Columbia"
      "British Columbia"
    when ".Canada-Manitoba"
      "Manitoba"
    when ".Canada-Newfoundland"
      "Newfoundland"
    when ".Canada-Northwest Territories"
      "Northwest Territories"
    when ".Canada-Nova Scotia"
      "Nova Scotia"
    when ".Canada-Nunavut"
      "Nunavut"
    when ".Canada-Ontario"
      "Ontario"
    when ".Canada-Quebec"
      "Quebec"
    when ".Canada-Saskatchewan"
      "Saskatchewan"
    else
      raise "Unknown Canadian province: #{location}"
    end
  end

  def download_file(url, dest)
    @mocks ||= {}
    @mocks[url] = dest
    super
  end
end
