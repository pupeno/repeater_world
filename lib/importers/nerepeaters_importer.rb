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

class NerepeatersImporter < Importer
  def self.source
    "http://www.nerepeaters.com/"
  end

  private

  EXPORT_URL = "http://www.nerepeaters.com/NERepeaters.php"

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

  def import_all_repeaters
    file_name = download_file(EXPORT_URL, "nerepeaters.csv")
    csv_file = CSV.table(file_name, headers: false)

    csv_file.each_with_index do |raw_repeater, line_number|
      yield(raw_repeater, line_number)
    end
  end

  def call_sign_and_tx_frequency(raw_repeater)
    [raw_repeater[CALL_SIGN].upcase, raw_repeater[TX_FREQUENCY].to_f * 10**6]
  end

  def import_repeater(raw_repeater, repeater)
    # Something odd is going on here, NE Repeaters claims this is Yaesu System Fusion, but gives a CTCSS code,
    # https://nedecn.org/maine-repeaters/buckfield-streaked-mtn-w1bkw/ and
    # https://nedecn.org/maine-repeaters/peru-w1bkw/ seem to point to it being DMR (color code), and
    # https://www.qrz.com/db/W1BKW seems to be a person, not a repeater.
    if raw_repeater[CALL_SIGN] == "W1BKW" && raw_repeater[MODE].strip == "YSF"
      @ignored_due_to_invalid_count += 1
      return
    end

    # K1PQ is there twice, with different data, so we are ignoring one of the two.
    if raw_repeater[CALL_SIGN] == "K1PQ" && raw_repeater[COMMENT] == "*Input: 146.400 (+0 kHz), 444.950 (Brownville,ME)"
      @ignored_due_to_invalid_count += 1
      return
    end

    repeater.band = RepeaterUtils.band_for_frequency(repeater.tx_frequency)
    repeater.rx_frequency = import_rx_frequency(repeater, raw_repeater)
    repeater.input_region = figure_out_us_state(raw_repeater[STATE])
    repeater.input_locality = raw_repeater[CITY]
    repeater.name = nil # It used to be "#{raw_repeater[CITY]} #{repeater.call_sign}", now it needs to be blank.
    import_mode(repeater, raw_repeater)
    import_access_code(repeater, raw_repeater)
    repeater.notes = "#{raw_repeater[COMMENT]}\nAccess codes: #{raw_repeater[ACCESS_CODE]} #{raw_repeater[ACCESS_CODE_2]}"

    repeater.input_country_id = "us"
    repeater.source = self.class.source
    repeater.save!

    repeater
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
    if repeater.call_sign == "KI1P" && repeater.tx_frequency == 445_075_000
      return 440_075_000 # Data is wrong, should be -, not + https://nedecn.org/home/repeaters/vermont-repeaters/bolton-ricker-mountain-ki1p/
    end
    if raw_repeater[RX_OFFSET].in? %w[- +] # Standard offsets.
      offsets.each do |offset|
        if repeater.tx_frequency >= offset[:min] && repeater.tx_frequency <= offset[:max]
          if raw_repeater[RX_OFFSET] == "-" && offset[:neg_offset].present?
            return repeater.tx_frequency + offset[:neg_offset]
          elsif raw_repeater[RX_OFFSET] == "+" && offset[:pos_offset].present?
            return repeater.tx_frequency + offset[:pos_offset]
          else
            raise "Unexpected offset #{raw_repeater[RX_OFFSET]} for frequency #{repeater.tx_frequency} in repeater #{raw_repeater}"
          end
        end
      end
    elsif raw_repeater[RX_OFFSET].in? ["*", "S"] # Some exceptions.
      if repeater.call_sign == "W1BST" && raw_repeater[COMMENT].include?(" 51.140 ")
        return 51_140_000
      elsif repeater.call_sign == "W1DSR" && raw_repeater[COMMENT].include?(" 147.975 ")
        return 147_975_000
      elsif repeater.call_sign == "KB1MMR" && raw_repeater[COMMENT].include?(" 147.415 ")
        return 147_415_000
      elsif repeater.call_sign == "WA1RJI" && raw_repeater[COMMENT].include?(" 147.445 ")
        return 147_445_000
      elsif repeater.call_sign == "W1NLK" && raw_repeater[COMMENT].include?(" 147.475 ")
        return 147_475_000
      elsif repeater.call_sign == "N1NTP" && raw_repeater[COMMENT].include?(" 147.885 ")
        return 147_885_000
      elsif repeater.call_sign == "NW1P" && raw_repeater[COMMENT].include?(" 441.700 ")
        return 441_700_000
      elsif repeater.call_sign == "W1ATD" && raw_repeater[COMMENT].include?(" 902.0625 ")
        return 902_062_500
      elsif repeater.call_sign == "N1JBC" && raw_repeater[COMMENT].include?(" 902.0625 ")
        return 902_062_500
      elsif repeater.call_sign == "W1DMR" && raw_repeater[COMMENT].include?(" 902.0625 ")
        return 902_062_500
      elsif repeater.call_sign == "WA1ABC" && raw_repeater[COMMENT].include?(" 902.0625 ")
        return 902_062_500
      elsif repeater.call_sign == "W1KK" && raw_repeater[COMMENT].include?(" 902.0625 ")
        return 902_062_500
      elsif repeater.call_sign == "W1SGL" && raw_repeater[COMMENT].include?(" 902.0625 ")
        return 902_062_500
      elsif repeater.call_sign == "W1AEC" && raw_repeater[COMMENT].include?(" 902.0625 ")
        return 902_062_500
      elsif repeater.call_sign == "K1RK" && raw_repeater[COMMENT].include?(" 902.0625 ")
        return 902_062_500
      elsif repeater.call_sign == "W1EHT" && raw_repeater[COMMENT].include?(" 902.0625 ")
        return 902_062_500
      elsif repeater.call_sign == "K1GHZ" && raw_repeater[COMMENT].include?(" 1270.1000 ")
        return 1_270_100_000
      elsif repeater.call_sign.in? %w[W1AFD W2FCC NO1A K1GAS KB1ISZ KB1ISZ NN1PA N1PA N1MYY KX1X KC1EGN NB1RI W1MLL K1IR
        K1KZP WE1CT KB1KVD W1STT KX1X WA1REQ W1AW AB1EX N1DOT WA3ITR W1SPC KB1VKY WX1PBD AA1TT KB1FX AA1PR WW1VT W1KK
        WB1GOF N1KIM]
        # No idea what's going on here, we just don't have the rx frequency.
        return repeater.tx_frequency
      else
        raise "Can't figure out rx frequency for offset #{raw_repeater[RX_OFFSET].inspect} and tx frequency #{repeater.tx_frequency} for #{raw_repeater}."
      end
    else
      raise "Unexpected offset #{raw_repeater[RX_OFFSET].inspect} for #{raw_repeater}."
    end
  end

  def import_mode(repeater, raw_repeater)
    # When a repeater changes mode, the old modes that are no longer there shouldn't remain set to true.
    repeater.disable_all_modes

    if raw_repeater[MODE].blank?
      repeater.fm = true # We are just assuming it's FM otherwise we'll be throwing away most of the data.
    elsif raw_repeater[MODE].strip == "NFM"
      repeater.fm = true
      repeater.bandwidth = Repeater::FM_NARROW
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
      repeater.bandwidth = Repeater::FM_NARROW
      repeater.nxdn = true
    elsif raw_repeater[MODE].strip == "YSF/FM"
      repeater.fm = true
      repeater.fusion = true
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
      repeater.bandwidth = Repeater::FM_NARROW
      repeater.p25 = true
    elsif raw_repeater[MODE].strip == "P25DMR/FM"
      repeater.fm = true
      repeater.dmr = true
      repeater.p25 = true
    elsif raw_repeater[MODE].strip == "P25YSFD-STAR"
      repeater.dstar = true
      repeater.fusion = true
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
    access_code = access_code.to_s.strip

    if repeater.fm? && access_code.to_d.in?(Repeater::CTCSS_TONES)
      repeater.fm_ctcss_tone = access_code.to_d
    elsif repeater.fm? && access_code.strip[0] == "D" && access_code[1..].to_i.in?(Repeater::DCS_CODES)
      repeater.fm_dcs_code = access_code[1..].to_i
    elsif RepeaterUtils.modes_as_sym(repeater) == Set[:fm, :p25] && access_code.split("/").second.to_d.in?(Repeater::CTCSS_TONES)
      # TODO: import the first part correctly, it's likely for P25.
      repeater.fm_ctcss_tone = access_code.split("/").second.to_d
    elsif RepeaterUtils.modes_as_sym(repeater) == Set[:fm, :nxdn] && access_code.split("/").second.to_d.in?(Repeater::CTCSS_TONES)
      # TODO: import the first part correctly, it's likely for NXDN.
      repeater.fm_ctcss_tone = access_code.split("/").second.to_d
    elsif RepeaterUtils.modes_as_sym(repeater) == Set[:fm, :p25] && access_code.in?(%w[NAC353/D244 NAC250/D244])
      # TODO: import the first part correctly, it's likely for P25.
      repeater.fm_dcs_code = 244
    elsif RepeaterUtils.modes_as_sym(repeater) == Set[:fm, :p25] && access_code.in?(%w[NAC671/D411])
      # TODO: import the first part correctly, it's likely for P25.
      repeater.fm_dcs_code = 411
    elsif RepeaterUtils.modes_as_sym(repeater) == Set[:fm, :dstar] &&
        access_code.split("/").first.in?(%w[A B C]) &&
        access_code.split("/").second.to_d.in?(Repeater::CTCSS_TONES)
      repeater.fm_ctcss_tone = access_code.split("/").second.to_d
      repeater.dstar_port = access_code.split("/").first
    elsif repeater.dmr? && (access_code =~ /CC[0-9]/ || access_code =~ /CC1[0-5]/)
      repeater.dmr_color_code = access_code.gsub("CC", "").to_i
    elsif repeater.dmr? && access_code.to_i.in?(Repeater::DMR_COLOR_CODES)
      repeater.dmr_color_code = access_code.to_i
    elsif repeater.dstar? && access_code.in?(%w[A B C])
      repeater.dstar_port = access_code
    elsif repeater.nxdn? && access_code.in?(%w[RAN1 RAN11 RAN2])
      # TODO: import these correctly.
    elsif repeater.p25? && access_code.in?(%w[NAC223 NAC401])
      # TODO: import these correctly.
    elsif access_code.blank?
      # Nothing we can do here really, we have no idea.
    else
      raise "Unknown access code \"#{access_code}\" (extracted form \"#{raw_repeater[ACCESS_CODE]}\" and \"#{raw_repeater[ACCESS_CODE_2]}\") when importing repeater #{raw_repeater}"
    end
  end
end
