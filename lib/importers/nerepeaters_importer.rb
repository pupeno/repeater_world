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

class NerepeatersImporter < Importer
  SOURCE = "http://www.nerepeaters.com/"
  EXPORT_URL = "http://www.nerepeaters.com/NERepeaters.php"

  def import
    @logger.info "Importing repeaters from #{SOURCE}."
    file_name = download_file(EXPORT_URL, "nerepeaters.csv")
    csv_file = CSV.table(file_name)

    ignored_due_to_source_count = 0
    ignored_due_to_invalid_count = 0
    created_or_updated_ids = []
    repeaters_deleted_count = 0

    Repeater.transaction do
      csv_file.each_with_index do |raw_repeater, line_number|
        action, imported_repeater = import_repeater(raw_repeater)
        if action == :ignored_due_to_source
          ignored_due_to_source_count += 1
        elsif action == :ignored_due_to_invalid
          ignored_due_to_invalid_count += 1
        else
          created_or_updated_ids << imported_repeater.id
        end
      rescue
        raise "Failed to import record on line #{line_number + 2}: #{raw_repeater}" # Line numbers start at 1, not 0, and there's a header, hence the +2
      end

      repeaters_deleted_count = Repeater.where(source: SOURCE).where.not(id: created_or_updated_ids).delete_all
    end

    @logger.info "Done importing from #{SOURCE}. #{created_or_updated_ids.count} created or updated, #{ignored_due_to_source_count} ignored due to source, #{ignored_due_to_invalid_count} ignored due to being invalid, and #{repeaters_deleted_count} deleted."
  end

  private

  # TODO: move this to a generic place if we get other use cases.
  US_STATES = {"AK" => "Alaska",
               "AL" => "Alabama",
               "AR" => "Arkansas",
               "AS" => "American Samoa",
               "AZ" => "Arizona",
               "CA" => "California",
               "CO" => "Colorado",
               "CT" => "Connecticut",
               "DC" => "District of Columbia",
               "DE" => "Delaware",
               "FL" => "Florida",
               "GA" => "Georgia",
               "GU" => "Guam",
               "HI" => "Hawaii",
               "IA" => "Iowa",
               "ID" => "Idaho",
               "IL" => "Illinois",
               "IN" => "Indiana",
               "KS" => "Kansas",
               "KY" => "Kentucky",
               "LA" => "Louisiana",
               "MA" => "Massachusetts",
               "MD" => "Maryland",
               "ME" => "Maine",
               "MI" => "Michigan",
               "MN" => "Minnesota",
               "MO" => "Missouri",
               "MS" => "Mississippi",
               "MT" => "Montana",
               "NC" => "North Carolina",
               "ND" => "North Dakota",
               "NE" => "Nebraska",
               "NH" => "New Hampshire",
               "NJ" => "New Jersey",
               "NM" => "New Mexico",
               "NV" => "Nevada",
               "NY" => "New York",
               "OH" => "Ohio",
               "OK" => "Oklahoma",
               "OR" => "Oregon",
               "PA" => "Pennsylvania",
               "PR" => "Puerto Rico",
               "RI" => "Rhode Island",
               "SC" => "South Carolina",
               "SD" => "South Dakota",
               "TN" => "Tennessee",
               "TX" => "Texas",
               "UT" => "Utah",
               "VA" => "Virginia",
               "VI" => "Virgin Islands",
               "VT" => "Vermont",
               "WA" => "Washington",
               "WI" => "Wisconsin",
               "WV" => "West Virginia",
               "WY" => "Wyoming"}

  # Columns
  TX_FREQUENCY = 0
  RX_OFFSET = 1
  STATE = 2
  CITY = 3
  MODE = 4
  CALL_SIGN = 5
  ACCESS_CODE = 6
  ACCESS_CODE_2 = 7 # What is this exactly? We are ignoring it for now.
  COUNTY = 9 # Is it county? no idea. We are not importing it.
  COMMENT = 12

  def import_repeater(raw_repeater)
    repeater = Repeater.find_or_initialize_by(call_sign: raw_repeater[CALL_SIGN].upcase,
      tx_frequency: raw_repeater[TX_FREQUENCY].to_f * 10**6)

    # Only update repeaters that were sourced from nerepeater.com.
    if repeater.persisted? && repeater.source != SOURCE && repeater.source != IrlpImporter.source
      @logger.info "Not updating #{repeater} since the source is #{repeater.source.inspect} and not #{SOURCE.inspect}"
      return [:ignored_due_to_source, repeater]
    end

    # Something odd is going on here, NE Repeaters claims this is Yaesu System Fusion, but gives a CTCSS code,
    # https://nedecn.org/maine-repeaters/buckfield-streaked-mtn-w1bkw/ and
    # https://nedecn.org/maine-repeaters/peru-w1bkw/ seem to point to it being DMR (color code), and
    # https://www.qrz.com/db/W1BKW seems to be a person, not a repeater.
    if raw_repeater[CALL_SIGN] == "W1BKW" && raw_repeater[MODE].strip == "YSF"
      return [:ignored_due_to_invalid, repeater]
    end

    import_rx_frequency(repeater, raw_repeater)
    repeater.region = US_STATES[raw_repeater[STATE]]
    repeater.locality = raw_repeater[CITY]
    repeater.name = "#{repeater.locality} #{repeater.call_sign}"
    import_mode(repeater, raw_repeater)
    import_access_code(repeater, raw_repeater)
    repeater.notes = "#{raw_repeater[COMMENT]}\nAccess codes: #{raw_repeater[ACCESS_CODE]} #{raw_repeater[ACCESS_CODE_2]}"

    fill_band(repeater)
    repeater.country_id = "us"
    repeater.source = SOURCE
    repeater.save!

    [:created_or_updated, repeater]
  rescue => e
    raise "Failed to save #{repeater.inspect} due to: #{e.message}"
  end

  def import_rx_frequency(repeater, raw_repeater)
    # https://rptr.amateur-radio.net/offset.html
    # TODO: make this generic if there are generic rules.
    offsets = [{min: 28_000_000, max: 29_700_000, neg_offset: -100_000}, # TODO: find the exact ones, I just guessed here.
      {min: 51_000_000, max: 52_000_000, neg_offset: -500_000},
      {min: 52_000_000, max: 54_000_000, neg_offset: -1_000_000},
      {min: 144_510_000, max: 144_890_000, pos_offset: +600_000},
      {min: 145_110_000, max: 145_490_000, neg_offset: -600_000},
      {min: 146_000_000, max: 146_390_000, pos_offset: +600_000},
      {min: 146_400_000, max: 146_500_000, pos_offset: +1_000_000, neg_offset: -1_500_000},
      {min: 146_610_000, max: 147_390_000, pos_offset: +600_000, neg_offset: -600_000}, # This one is modified because the data wasn't consistent.
      {min: 147_400_000, max: 147_600_000, neg_offset: -1_000_000},
      {min: 147_600_000, max: 147_990_000, neg_offset: -600_000},
      {min: 223_000_000, max: 225_000_000, neg_offset: -1_600_000},
      {min: 440_000_000, max: 450_000_000, pos_offset: 5_000_000, neg_offset: -5_000_000},
      {min: 902_000_000, max: 928_000_000, neg_offset: -12_000_000},
      {min: 927_000_000, max: 928_000_000, neg_offset: -25_000_000},
      {min: 1240_000_000, max: 1300_000_000, neg_offset: -20_000_000}] # TODO: find the exact ones, I just guessed here.
    if raw_repeater[RX_OFFSET].in? %w[- +] # Standard offsets.
      offsets.each do |offset|
        if repeater.tx_frequency >= offset[:min] && repeater.tx_frequency <= offset[:max]
          if raw_repeater[RX_OFFSET] == "-" && offset[:neg_offset].present?
            repeater.rx_frequency = repeater.tx_frequency + offset[:neg_offset]
          elsif raw_repeater[RX_OFFSET] == "+" && offset[:pos_offset].present?
            repeater.rx_frequency = repeater.tx_frequency + offset[:pos_offset]
          end
        end
      end
    elsif raw_repeater[RX_OFFSET].in? ["*", "S"] # Some exceptions.
      if repeater.call_sign == "W1BST" && raw_repeater[COMMENT]&.include?(" 51.140 ")
        repeater.rx_frequency = 51_140_000
      elsif repeater.call_sign == "W1DSR" && raw_repeater[COMMENT]&.include?(" 147.975 ")
        repeater.rx_frequency = 147_975_000
      elsif repeater.call_sign == "K1BEP" # it seems to be just a D-Star gateway, not a repeater
        repeater.rx_frequency = repeater.tx_frequency
      elsif repeater.call_sign == "KB1MMR" && raw_repeater[COMMENT]&.include?(" 147.415 ")
        repeater.rx_frequency = 147_415_000
      elsif repeater.call_sign == "WA1RJI" && raw_repeater[COMMENT]&.include?(" 147.445 ")
        repeater.rx_frequency = 147_445_000
      elsif repeater.call_sign == "W1NLK" && raw_repeater[COMMENT]&.include?(" 147.475 ")
        repeater.rx_frequency = 147_475_000
      elsif repeater.call_sign == "K1IFF" && raw_repeater[COMMENT]&.include?(" 147.5925 ")
        repeater.rx_frequency = 147_592_500
      elsif repeater.call_sign == "N1NTP" && raw_repeater[COMMENT]&.include?(" 147.885 ")
        repeater.rx_frequency = 147_885_000
      elsif repeater.call_sign == "NW1P" && raw_repeater[COMMENT]&.include?(" 441.700 ")
        repeater.rx_frequency = 441_700_000
      elsif repeater.call_sign == "W1ATD" && raw_repeater[COMMENT]&.include?(" 902.0625 ")
        repeater.rx_frequency = 902_062_500
      elsif repeater.call_sign == "N1JBC" && raw_repeater[COMMENT]&.include?(" 902.0625 ")
        repeater.rx_frequency = 902_062_500
      elsif repeater.call_sign == "W1DMR" && raw_repeater[COMMENT]&.include?(" 902.0625 ")
        repeater.rx_frequency = 902_062_500
      elsif repeater.call_sign == "WA1ABC" && raw_repeater[COMMENT]&.include?(" 902.0625 ")
        repeater.rx_frequency = 902_062_500
      elsif repeater.call_sign == "W1KK" && raw_repeater[COMMENT]&.include?(" 902.0625 ")
        repeater.rx_frequency = 902_062_500
      elsif repeater.call_sign == "W1SGL" && raw_repeater[COMMENT]&.include?(" 902.0625 ")
        repeater.rx_frequency = 902_062_500
      elsif repeater.call_sign == "W1AEC" && raw_repeater[COMMENT]&.include?(" 902.0625 ")
        repeater.rx_frequency = 902_062_500
      elsif repeater.call_sign == "K1RK" && raw_repeater[COMMENT]&.include?(" 902.0625 ")
        repeater.rx_frequency = 902_062_500
      elsif repeater.call_sign == "K1GHZ" && raw_repeater[COMMENT]&.include?(" 1270.1000 ")
        repeater.rx_frequency = 1_270_100_000
      elsif repeater.call_sign.in? %w[W1AFD W2FCC NO1A K1GAS KB1ISZ KB1ISZ NN1PA N1PA N1MYY KX1X KC1EGN NB1RI W1MLL K1IR
        K1KZP WE1CT KB1KVD W1STT KX1X WA1REQ W1AW AB1EX N1DOT WA3ITR W1SPC KB1VKY WX1PBD AA1TT KB1FX AA1PR WW1VT W1KK
        WB1GOF]
        repeater.rx_frequency = repeater.tx_frequency # No idea what's going on here, we just don't have the rx frequency.
      end
    end
    if repeater.rx_frequency.blank?
      raise "Unknown rx frequency for tx frequency #{repeater.tx_frequency} with symbol \"#{raw_repeater[RX_OFFSET]}\"."
    end
  end

  def import_mode(repeater, raw_repeater)
    if raw_repeater[MODE].blank?
      repeater.fm = true # We are just assuming it's FM otherwise we'll be throwing away most of the data.
    elsif raw_repeater[MODE].strip == "NFM"
      repeater.fm = true
      repeater.fm_bandwidth = Repeater::FM_NARROW
    elsif raw_repeater[MODE].strip == "D-STAR"
      repeater.dstar = true
    elsif raw_repeater[MODE].strip == "YSF"
      repeater.fusion = true
    elsif raw_repeater[MODE].strip == "DMR"
      repeater.dmr = true
    elsif raw_repeater[MODE].strip == "NXDN"
      repeater.nxdn = true
    elsif raw_repeater[MODE].strip == "P25"
      repeater.p25 = true
    elsif raw_repeater[MODE].strip == "D-STARDMR"
      repeater.dstar = true
      repeater.dmr = true
    elsif raw_repeater[MODE].strip == "D-STAR/FM"
      repeater.fm = true
      repeater.dstar = true
    elsif raw_repeater[MODE].strip == "NXDN/NFM"
      repeater.fm = true
      repeater.fm_bandwidth = Repeater::FM_NARROW
      repeater.nxdn = true
    elsif raw_repeater[MODE].strip == "YSF/FM"
      repeater.fm = true
      repeater.fusion = true
    elsif raw_repeater[MODE].strip == "DMR/NFM"
      repeater.fm = true
      repeater.fm_bandwidth = Repeater::FM_NARROW
      repeater.dmr = true
    elsif raw_repeater[MODE].strip == "DMR/FM"
      repeater.fm = true
      repeater.dmr = true
    elsif raw_repeater[MODE].strip == "NXDN/FM"
      repeater.fm = true
      repeater.nxdn = true
    elsif raw_repeater[MODE].strip == "P25/FM"
      repeater.fm = true
      repeater.p25 = true
    elsif raw_repeater[MODE].strip == "P25/NFM"
      repeater.fm = true
      repeater.fm_bandwidth = Repeater::FM_NARROW
      repeater.p25 = true
    elsif raw_repeater[MODE].strip == "P25DMR/FM"
      repeater.fm = true
      repeater.dmr = true
      repeater.p25 = true
    elsif raw_repeater[MODE].strip == "YSFD-STAR/FM"
      repeater.fm = true
      repeater.dstar = true
      repeater.fusion = true
    elsif raw_repeater[MODE].strip == "P25YSFD-STARNXDNDMR"
      repeater.dstar = true
      repeater.fusion = true
      repeater.dmr = true
      repeater.nxdn = true
      repeater.p25 = true
    elsif raw_repeater[MODE].strip == "P25YSFD-STARNXDNDMR/FM"
      repeater.fm = true
      repeater.dstar = true
      repeater.fusion = true
      repeater.dmr = true
      repeater.nxdn = true
      repeater.p25 = true
    else
      raise "Unknown mode \"#{raw_repeater[MODE]}\" when importing repeater #{raw_repeater}"
    end
  end

  def import_access_code(repeater, raw_repeater)
    access_code = raw_repeater[ACCESS_CODE]
    if access_code.blank?
      access_code = raw_repeater[ACCESS_CODE_2]
    end
    access_code = access_code.to_s
    access_code = access_code.strip if access_code.respond_to? :strip

    if repeater.fm? && access_code.to_f&.in?(Repeater::CTCSS_TONES)
      repeater.fm_ctcss_tone = access_code.to_f
    elsif repeater.modes == Set[:fm, :p25] && access_code.split("/").second.to_f.in?(Repeater::CTCSS_TONES)
      # TODO: import the first part correctly, it's likely for P25.
      repeater.fm_ctcss_tone = access_code.split("/").second.to_f
    elsif repeater.modes == Set[:fm, :nxdn] && access_code.split("/").second.to_f.in?(Repeater::CTCSS_TONES)
      # TODO: import the first part correctly, it's likely for NXDN.
      repeater.fm_ctcss_tone = access_code.split("/").second.to_f
    elsif repeater.modes == Set[:fm, :p25] && access_code.in?(%w[NAC353/D244 NAC250/D244])
      # TODO: import the first part correctly, it's likely for P25.
      # TODO: what's the second part? What are these D numbers?
    elsif repeater.modes == Set[:fm, :dstar] &&
        access_code.split("/").first.in?(%w[A B C]) &&
        access_code.split("/").second.to_f.in?(Repeater::CTCSS_TONES)
      repeater.fm_ctcss_tone = access_code.split("/").second.to_f
      repeater.dstar_port = access_code.split("/").first.in?(%w[A B C])
    elsif repeater.dmr? && (access_code =~ /CC[0-9]/ || access_code =~ /CC1[0-5]/)
      repeater.dmr_color_code = access_code.gsub("CC", "").to_i
    elsif repeater.dmr? && access_code.to_i.in?(Repeater::DMR_COLOR_CODES)
      repeater.dmr_color_code = access_code.to_i
    elsif repeater.dstar? && access_code.in?(%w[A B C])
      repeater.dstar_port = access_code
    elsif repeater.nxdn? && access_code.in?(%w[RAN1 RAN11 RAN2])
      # TODO: import these correctly.
    elsif repeater.p25? && access_code.in?(["NAC223"])
      # TODO: import these correctly.
    elsif repeater.fm? && access_code.in?(%w[D244 D432 D023 D073 D411 D031 D051 D245 D271])
      # TODO: what is this?
    elsif access_code.blank?
      # Nothing we can do here really, we have no idea.
    else
      raise "Unknown access code \"#{access_code}\" (extracted form \"#{raw_repeater[ACCESS_CODE]}\" and \"#{raw_repeater[ACCESS_CODE_2]}\") when importing repeater #{raw_repeater}"
    end
  end

  def fill_band(repeater)
    # TODO: this can probably be generalized and moved to the Repeater model.
    bands = [{min: 28_000_000, max: 29_700_000, band: Repeater::BAND_10M},
      {min: 50_000_000, max: 54_000_000, band: Repeater::BAND_6M},
      {min: 144_000_000, max: 148_000_000, band: Repeater::BAND_2M},
      {min: 222_000_000, max: 225_000_000, band: Repeater::BAND_1_25M},
      {min: 420_000_000, max: 450_000_000, band: Repeater::BAND_70CM},
      {min: 902_000_000, max: 928_000_000, band: Repeater::BAND_33CM},
      {min: 1240_000_000, max: 1300_000_000, band: Repeater::BAND_23CM}]
    bands.each do |band|
      if repeater.tx_frequency >= band[:min] && repeater.tx_frequency < band[:max]
        repeater.band = band[:band]
        break
      end
    end
    if repeater.band.blank?
      raise "Unknown band for tx frequency #{repeater.tx_frequency}."
    end
  end
end
