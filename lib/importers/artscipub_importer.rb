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

class ArtscipubImporter < Importer
  def self.source
    "http://www.artscipub.com/repeaters/"
  end

  private

  EXPORT_URL = "http://www.artscipub.com/repeaters/"

  def import_all_repeaters
    raw_repeaters = get_raw_repeaters

    raw_repeaters.each_with_index do |raw_repeater, index|
      yield(raw_repeater, index)
    end
  end

  def call_sign_and_tx_frequency(raw_repeater)
    if raw_repeater[:call_sign] == "W6SAR" && raw_repeater[:frequency] == "164.640-" # Typo in the freq.
      raw_repeater[:frequency] = "146.640-"
    elsif raw_repeater[:call_sign] == "N1KGN" && raw_repeater[:frequency] == "141.7+" # Typo in the freq.
      raw_repeater[:frequency] = "441.7+"
    elsif raw_repeater[:call_sign] == "W4MOT" && raw_repeater[:frequency] == "149.790-" # Typo in the freq.
      raw_repeater[:frequency] = "147.105+"
    end
    [raw_repeater[:call_sign].tr("Ø", "0").upcase, raw_repeater[:frequency].to_f * 10**6]
  end

  def import_repeater(raw_repeater, repeater)
    if raw_repeater[:comments].downcase.include?("noaa") || # Not importing NOAA weather stations. Should we?
        raw_repeater[:web_site].downcase.include?("noaa") || # Not importing NOAA weather stations. Should we?
        raw_repeater[:web_site].downcase.include?("weather.gov") || # Not importing NOAA weather stations. Should we?
        raw_repeater[:call_sign].blank? || # Can't import a repeater without a call sign.
        raw_repeater[:frequency].blank? || raw_repeater[:frequency].to_f < 1 || # Can't import a repeater without a frequency.
        raw_repeater[:call_sign] =~ /[a-zA-Z]{3,4}[-\s]?\d{3,4}/ || # Only interested in ham radio, not GMRS: https://github.com/pupeno/repeater_world/issues/264
        raw_repeater[:comments].downcase.include?("gmrs") || # Only interested in ham radio, not GMRS: https://github.com/pupeno/repeater_world/issues/264
        raw_repeater[:web_site].downcase.include?("gmrs") || # Only interested in ham radio, not GMRS: https://github.com/pupeno/repeater_world/issues/264
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
        raw_repeater[:call_sign] == "private" || # Frequency out of band plan, not a call sign..
        raw_repeater[:pl_tone].downcase.in?(["gone", "closed", "private"]) || # Closed repeaters.
        raw_repeater[:call_sign] == "General" || # Frequency out of band plan, not a call sign.
        raw_repeater[:call_sign] == "154.445" # Not a valid call sign, data entry error.
      @ignored_due_to_invalid_count += 1
      return
    end

    repeater.name = nil # If there's no explicit name, we should keep it blank.
    repeater.external_id = raw_repeater[:external_id]

    repeater.rx_frequency = parse_rx_frequency(repeater, raw_repeater)
    repeater.band = RepeaterUtils.band_for_frequency(repeater.tx_frequency)
    if !RepeaterUtils.is_frequency_in_band?(repeater.rx_frequency, repeater.band)
      repeater.cross_band = true
    end
    import_mode_and_access_codes(repeater, raw_repeater)

    import_address(repeater, raw_repeater)
    repeater.input_grid_square = raw_repeater[:grid_square] if raw_repeater[:grid_square].present?
    if raw_repeater[:latitude].present? && raw_repeater[:longitude].present?
      latitude = raw_repeater[:latitude].to_f
      longitude = raw_repeater[:longitude].to_f

      if (-90..90).cover?(latitude) && (-180..180).cover?(longitude) && latitude != 0 && longitude != 0
        repeater.latitude = latitude
        repeater.longitude = longitude
      else
        repeater.coordinates = nil
      end
    end

    repeater.notes = raw_repeater[:comments] if raw_repeater[:comments].present?

    repeater.source = self.class.source
    repeater.save!

    repeater
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
      File.binwrite(raw_repeaters_file_name, Marshal.dump(raw_repeaters))

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
    raw_repeater[:call_sign] = table.at_xpath("tr[td[normalize-space() = 'Call Sign']]/td[2]").text.strip
    raw_repeater[:coordinates] = table.at_xpath("tr[td[normalize-space() = 'Location']]/td[2]").text.strip
    raw_repeater[:frequency] = table.at_xpath("tr[td[normalize-space() = 'Frequency']]/td[2]").text.strip
    raw_repeater[:input] = table.at_xpath("tr[td[normalize-space() = 'Input']]/td[2]").text.strip
    raw_repeater[:pl_tone] = table.at_xpath("tr[td[normalize-space() = 'PL Tone']]/td[2]").text.strip
    raw_repeater[:rating] = table.at_xpath("tr[td[normalize-space() = 'Rating']]/td[2]").text.strip
    raw_repeater[:auto_patch] = table.at_xpath("tr[td[normalize-space() = 'Auto Patch']]/td[2]").text.strip
    raw_repeater[:web_site] = table.at_xpath("tr[td[normalize-space() = 'Web Site']]/td[2]").text.strip
    raw_repeater[:grid_square] = table.at_xpath("tr[td[normalize-space() = 'Grid Square']]/td[2]").text.strip
    raw_repeater[:zip_code] = table.at_xpath("tr[td[normalize-space() = 'Zip Code.']]/td[2]//b").text.strip # This one is different, because there's some cruft in this cell.
    raw_repeater[:latitude] = table.at_xpath("tr[td[normalize-space() = 'Latitude']]/td[2]").text.strip
    raw_repeater[:longitude] = table.at_xpath("tr[td[normalize-space() = 'Longitude']]/td[2]").text.strip
    raw_repeater[:comments] = table.at_xpath("tr[td[normalize-space() = 'Comments']]/td[2]").text.strip

    raw_repeater
  end

  def parse_rx_frequency(repeater, raw_repeater)
    if raw_repeater[:input].present?
      raw_repeater[:input].to_f * 10**6
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

  def import_mode_and_access_codes(repeater, raw_repeater)
    # When a repeater changes mode, the old modes that are no longer there shouldn't remain set to true.
    repeater.disable_all_modes

    pl_tone = raw_repeater[:pl_tone].downcase
    if pl_tone.to_f.in?(Repeater::CTCSS_TONES)
      repeater.fm = true
      repeater.fm_ctcss_tone = pl_tone.to_f
    elsif pl_tone.in? ["79.9", "71,9"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 71.9
    elsif pl_tone == "79.9"
      repeater.fm = true
      repeater.fm_ctcss_tone = 79.7
    elsif pl_tone == "88"
      repeater.fm = true
      repeater.fm_ctcss_tone = 88.5
    elsif pl_tone.in? ["98.4", "94.6"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 94.8
    elsif pl_tone.in? ["94.7", "tx pl 97.4"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 97.4
    elsif pl_tone.in? ["[100.0]", "[100]"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 100.0
    elsif pl_tone.in? ["105.3", "[103.5]", "103.0", "102.3", "103..5", "103.6"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 103.5
    elsif pl_tone.in? ["107.9", "107.3", "102.7"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 107.2
    elsif pl_tone.in? ["110", "110.5", "109.0"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 110.9
    elsif pl_tone == "114.3"
      repeater.fm = true
      repeater.fm_ctcss_tone = 114.8
    elsif pl_tone == "118.0"
      repeater.fm = true
      repeater.fm_ctcss_tone = 118.8
    elsif pl_tone.in? ["123.3", "123.5", "csq /123"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 123
    elsif pl_tone == "[127.3]"
      repeater.fm = true
      repeater.fm_ctcss_tone = 127.3
    elsif pl_tone.in? ["131", "131,8", "131.5"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 131.8
    elsif pl_tone.in? ["136.6", "130.5"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 136.5
    elsif pl_tone == "141.0"
      repeater.fm = true
      repeater.fm_ctcss_tone = 141.3
    elsif pl_tone.in? ["[146.2]", "146.3"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 146.2
    elsif pl_tone == "161.1"
      repeater.fm = true
      repeater.fm_ctcss_tone = 162.2
    elsif pl_tone.in? ["173", "ctcs 173.8"]
      repeater.fm = true
      repeater.fm_ctcss_tone = 173.8
    elsif pl_tone == "203.7"
      repeater.fm = true
      repeater.fm_ctcss_tone = 203.5
    elsif pl_tone == "[pl 210.7]"
      repeater.fm = true
      repeater.fm_ctcss_tone = 210.7
    elsif pl_tone == "pl 218.1"
      repeater.fm = true
      repeater.fm_ctcss_tone = 218.1
    elsif pl_tone == "248.8"
      repeater.fm = true
      repeater.fm_ctcss_tone = 241.8
    elsif pl_tone == "254.1"
      repeater.fm = true
      repeater.fm_ctcss_tone = 250.3
    elsif pl_tone.in? ["023", "23", "d023n", "dcs 023", "dcs023"]
      repeater.fm = true
      repeater.fm_dcs_code = 23
    elsif pl_tone.in? ["[026]", "[dcs 26]"]
      repeater.fm = true
      repeater.fm_dcs_code = 26
    elsif pl_tone.in? ["[d031]"]
      repeater.fm = true
      repeater.fm_dcs_code = 31
    elsif pl_tone.in? ["dcs32"]
      repeater.fm = true
      repeater.fm_dcs_code = 32
    elsif pl_tone.in? ["047", "d047"]
      repeater.fm = true
      repeater.fm_dcs_code = 47
    elsif pl_tone.in? ["d051"]
      repeater.fm = true
      repeater.fm_dcs_code = 51
    elsif pl_tone.in? ["dpl-071", "dpl 071"]
      repeater.fm = true
      repeater.fm_dcs_code = 71
    elsif pl_tone.in? ["073", "d073", "dpl-073", "dcs - 073"]
      repeater.fm = true
      repeater.fm_dcs_code = 73
    elsif pl_tone.in? ["dcs 115"]
      repeater.fm = true
      repeater.fm_dcs_code = 115
    elsif pl_tone.in? ["d125n", "dpl125"]
      repeater.fm = true
      repeater.fm_dcs_code = 125
    elsif pl_tone.in? ["dpl134"]
      repeater.fm = true
      repeater.fm_dcs_code = 134
    elsif pl_tone.in? ["152d"]
      repeater.fm = true
      repeater.fm_dcs_code = 152
    elsif pl_tone.in? ["dpl156"]
      repeater.fm = true
      repeater.fm_dcs_code = 156
    elsif pl_tone.in? ["d172"]
      repeater.fm = true
      repeater.fm_dcs_code = 172
    elsif pl_tone.in? ["d174"]
      repeater.fm = true
      repeater.fm_dcs_code = 174
    elsif pl_tone.in? ["dcs 205"]
      repeater.fm = true
      repeater.fm_dcs_code = 205
    elsif pl_tone.in? ["244", "[d 244n]", "dpl244"]
      repeater.fm = true
      repeater.fm_dcs_code = 244
    elsif pl_tone.in? ["d245n"]
      repeater.fm = true
      repeater.fm_dcs_code = 245
    elsif pl_tone.in? ["d263"]
      repeater.fm = true
      repeater.fm_dcs_code = 263
    elsif pl_tone.in? ["d311", "[311]", "dpl 311", "dcs 311"]
      repeater.fm = true
      repeater.fm_dcs_code = 311
    elsif pl_tone.in? ["dpl343"]
      repeater.fm = true
      repeater.fm_dcs_code = 343
    elsif pl_tone.in? ["[dpl 351]"]
      repeater.fm = true
      repeater.fm_dcs_code = 351
    elsif pl_tone.in? ["365n", "[365n]"]
      repeater.fm = true
      repeater.fm_dcs_code = 365
    elsif pl_tone.in? ["d411", "dpl 411", "411 [dpl]"]
      repeater.fm = true
      repeater.fm_dcs_code = 411
    elsif pl_tone.in? ["d432", "432", "dcs 432", "dpl 432"]
      repeater.fm = true
      repeater.fm_dcs_code = 432
    elsif pl_tone.in? ["d455", "dpl 455"]
      repeater.fm = true
      repeater.fm_dcs_code = 445
    elsif pl_tone.in? ["dpl 503"]
      repeater.fm = true
      repeater.fm_dcs_code = 503
    elsif pl_tone.in? ["dpl532"]
      repeater.fm = true
      repeater.fm_dcs_code = 532
    elsif pl_tone.in? ["d 606", "dpl606"]
      repeater.fm = true
      repeater.fm_dcs_code = 606
    elsif pl_tone.in? ["654"]
      repeater.fm = true
      repeater.fm_dcs_code = 654
    elsif pl_tone.in? ["d732n"]
      repeater.fm = true
      repeater.fm_dcs_code = 732
    elsif pl_tone.in?(["none", "no", "open", "n/a", "no [no]"])
      repeater.fm = true
      repeater.fm_tone_burst = true # Just guessing here.
    elsif pl_tone.in? ["a"]
      repeater.dstar = true
      repeater.dstar_port = "A"
    elsif pl_tone.in? ["c"]
      repeater.dstar = true
      repeater.dstar_port = "C"
    elsif pl_tone.in?(["d-star", "dstar", "dv", "na [dstar]", "d star"]) ||
        (pl_tone.blank? && raw_repeater[:comments].include?("D-STAR"))
      repeater.dstar = true
    elsif raw_repeater[:comments].include?("D-STAR GATEWAY DATA PORT A")
      repeater.dstar = true
      repeater.dstar_port = "A"
    elsif pl_tone == "fusion" ||
        raw_repeater[:comments] == "Yaesu Fusion repeater Digital code 009"
      repeater.fusion = true
    elsif pl_tone == "c4fm"
      repeater.fm = true
      repeater.fusion = true
    elsif pl_tone == "c4fm/136.5"
      repeater.fm = true
      repeater.fm_ctcss_tone = 136.5
      repeater.fusion = true
    elsif pl_tone.in? ["dmr", "[dmr]", "[dmr ]", "dmr digital", "dmr only", "dmr only!", "[dmrplus]"]
      repeater.dmr = true
    elsif pl_tone == "dmr" && raw_repeater[:comments].include?("BrandMeister")
      repeater.dmr = true
      repeater.dmr_network = "Brandmeister"
    elsif pl_tone.in? ["[cc 0]"]
      repeater.dmr = true
      repeater.dmr_color_code = 0
    elsif pl_tone.in? ["dmr cc1", "[cc1]", "cc 1", "cc1 [csq]", "cc1", "[cc 1]", "color code 1", "color code 1 dmr",
      "code 1", "ts1 cc1"]
      repeater.dmr = true
      repeater.dmr_color_code = 1
    elsif pl_tone.in? ["cc2", "cc 2", "[cc2]"]
      repeater.dmr = true
      repeater.dmr_color_code = 2
    elsif pl_tone.in? ["cc3", "cc 3", "[cc 3]", "cc 3 [cc3]"]
      repeater.dmr = true
      repeater.dmr_color_code = 3
    elsif pl_tone == "[cc 4]"
      repeater.dmr = true
      repeater.dmr_color_code = 4
    elsif pl_tone.in? ["[cc 7]", "cc7", "[cc7]", "ccode 1 [ccs7 /dmr ]"]
      repeater.dmr = true
      repeater.dmr_color_code = 7
    elsif pl_tone.in? ["[cc 8]", "cc8", "[cc8]"]
      repeater.dmr = true
      repeater.dmr_color_code = 8
    elsif pl_tone.in? ["[cc 9]", "cc9", "[cc9]"]
      repeater.dmr = true
      repeater.dmr_color_code = 9
    elsif pl_tone == "[cc 11]"
      repeater.dmr = true
      repeater.dmr_color_code = 11
    elsif pl_tone == "cc12"
      repeater.dmr = true
      repeater.dmr_color_code = 12
    elsif (pl_tone.include?("cc 11") || pl_tone.include?("cc11")) && raw_repeater[:comments].include?("BRANDMEISTER")
      repeater.dmr = true
      repeater.dmr_color_code = 11
      repeater.dmr_network = "Brandmeister"
    elsif pl_tone == "cc0 151.4"
      repeater.fm = true
      repeater.fm_ctcss_tone = 151.4
      repeater.dmr = true
      repeater.dmr_color_code = 0
    elsif pl_tone == "nxdn"
      repeater.nxdn = true
    elsif pl_tone.in?(["ran1", "ran 1", "[ran 1]", "ran01", "[ran2]", "[ran 11]"])
      repeater.nxdn = true # TODO: properly import RAN1, but figure out what it is first.
    elsif (pl_tone == "[cc1/nac293]" && raw_repeater[:comments].include?("DStar DMR Fusion P25")) || # TODO: properly import NAC293, but figure out what it is first.
        (pl_tone == "[digital]" && raw_repeater[:comments].include?("DMR CC1 SLOT 1 TG 33033 LINKED TO YSF - 0 KP3AV REFLECTOR C4FM DISTAR P25"))
      repeater.dstar = true
      repeater.fusion = true
      repeater.dmr = true
      repeater.dmr_color_code = 1
      repeater.p25 = true
    elsif pl_tone.blank? || # Can't do much here.
        pl_tone.downcase.in?(["yes", "29.54", "448.35", "449.275", "52.35", "atv", "data", "dts", "lafayette", "0",
          "yes", "[dtmf]", "[dtmf5]", "5z", "[*]", "[nac]", "dtmf", "video", "tg99", "rock hill", "[nac 293]", "csq",
          "[dgid:00]", "[visit srg]", "600", "atikokan", "cochin", "[nac$293]", "am atv", "ran 11", "293"]) # No idea what this is...
      # ...so not doing anything here.
    else
      raise "Unknown mode and access code \"#{pl_tone}\" for #{raw_repeater}."
    end
  end

  def import_address(repeater, raw_repeater)
    coordinates = raw_repeater[:coordinates].split(",").map(&:strip).reject(&:empty?)

    if coordinates.last.start_with?(".") || # This is how non US locations are formatted...
        coordinates.first.start_with?(".") || # ...except when the dot got added to the other part...
        coordinates.last == "Sonora" # ...or when it's just another place, _sigh_
      repeater.input_country_id = figure_out_country(coordinates)

      case repeater.input_country_id
      when "ca"
        repeater.input_region = figure_out_canadian_province(coordinates.last)
        repeater.input_locality = coordinates[0..-2].join(", ")
      when "gb"
        case coordinates.last
        when ".England"
          repeater.input_locality = coordinates[0..-2].join(", ")
          repeater.input_region = "England"
        when ".Norfolk-England"
          repeater.input_locality = coordinates[0..-2].join(", ")
          repeater.input_region = "England"
        when ".Scotland" # Not actually imported since we already have them, likely from ukrepeaters.
          repeater.input_locality = coordinates[0..-2].join(", ")
          repeater.input_region = "Scotland"
        else
          raise "Unknown UK location: #{coordinates.inspect}"
        end
      when "in"
        case coordinates.last
        when ".india"
          repeater.input_region = coordinates[0..-2].join(", ")
        when ".Tamilnadu", ".TAMILNADU"
          repeater.input_locality = coordinates[0..-2].join(", ")
          repeater.input_region = "Tamil Nadu"
        when ".TANIL NADU INDIA"
          repeater.input_locality = coordinates[0..-2].join(", ")
          repeater.input_region = "Tamil Nadu"
        end
      else
        if coordinates.length == 2 # Second is the country.
          repeater.input_region = coordinates.first
        elsif coordinates.length == 3 # Third is the country.
          repeater.input_locality = coordinates.first
          repeater.input_region = coordinates.second
        else
          raise "Unknown amount of location parts: #{coordinates.inspect}"
        end
      end
    else
      repeater.input_country_id = "us"
      repeater.input_locality = coordinates[0..-2].join(", ")
      repeater.input_region = figure_out_us_state(coordinates.last)
      repeater.input_post_code = raw_repeater[:zip_code] if raw_repeater[:zip_code].present? && raw_repeater[:zip_code] != "00000"
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
    when ".Mexico", ".mexico", ".Baja California", ".Sinaloa", ".Sonora", "Mexico", "Sonora"
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

  def download_file(url, dest)
    @mocks ||= {}
    @mocks[url] = dest
    super
  end
end
