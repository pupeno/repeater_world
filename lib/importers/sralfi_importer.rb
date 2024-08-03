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

class SralfiImporter < Importer
  def self.source
    "https://automatic.sral.fi/?p=export"
  end

  private

  EXPORT_URL = "https://automatic.sral.fi/api-v1.php?query=list"

  BAND_MAPPING = {
    "28MHz/10m" => Repeater::BAND_10M,
    "50MHz/6m" => Repeater::BAND_6M,
    "70MHz/4m" => Repeater::BAND_4M,
    "144MHz/2m" => Repeater::BAND_2M,
    "145MHz/2m" => Repeater::BAND_2M,
    "432MHz/70cm" => Repeater::BAND_70CM,
    "433MHz/70cm" => Repeater::BAND_70CM,
    "1296MHz/23cm" => Repeater::BAND_23CM
  }

  def import_all_repeaters
    file_name = download_file(EXPORT_URL, "sralfi_export.json")
    stations = JSON.parse(File.read(file_name))

    stations["stations"].each_with_index do |raw_repeater, index|
      # Types:
      # 1: Voice repeater,
      # 2: Beacon,
      # 3: APRS digipeater,
      # 4: ATV repeater,
      # 5: Data networks.
      # https://m.pablofernandez.tech/@oh8hub@mastodon.radio/110406906005017761
      # TODO: decide whether to add anything other than voice repeaters.
      if raw_repeater["type"] == "1"
        yield(raw_repeater, index)
      end
    end
  end

  def call_sign_and_tx_frequency(raw_repeater)
    [raw_repeater["callsign"].upcase, raw_repeater["tx_freq"].to_f * 10**6]
  end

  def import_repeater(raw_repeater, repeater)
    repeater.external_id = raw_repeater["id"]
    import_status(raw_repeater, repeater)
    import_mode(raw_repeater, repeater)
    import_name(raw_repeater, repeater)
    repeater.web_site = raw_repeater["station_url"] || raw_repeater["responsible_club_url"]
    # stdesc imported later
    # TODO: what is cwid? It has some of these values: VJ, RI, KT, KA, JA, JY, JM, KO, OU, RO.
    repeater.input_locality = raw_repeater["qth_city"]
    repeater.input_grid_square = raw_repeater["locator"]
    repeater.input_latitude = raw_repeater["wgs84lat"]
    repeater.input_longitude = raw_repeater["wgs84lon"]
    # site_desc imported later
    repeater.altitude_asl = raw_repeater["alt_asl"]
    repeater.altitude_agl = raw_repeater["alt_agl"]
    repeater.tx_frequency = raw_repeater["tx_freq"].to_f * 10**6
    repeater.tx_power = raw_repeater["tx_power"]
    repeater.tx_antenna = raw_repeater["tx_ant"]
    import_tx_antenna_polarization(raw_repeater, repeater)
    repeater.bearing = raw_repeater["qtf"]
    repeater.rx_antenna = raw_repeater["rx_antenna"]
    import_rx_antenna_polarization(raw_repeater, repeater)
    import_access_method(raw_repeater, repeater)
    import_rx_frequency(raw_repeater, repeater)

    repeater.band = BAND_MAPPING[raw_repeater["band_name"].strip] || raise("Unknown band #{raw_repeater["band_name"]}")
    repeater.keeper = raw_repeater["responsible_club"]
    # responsible_club_url imported earlier/later
    # remarks imported later

    import_notes(raw_repeater, repeater)

    repeater.source = self.class.source
    repeater.redistribution_limitations = data_limitations_sral_fi_url(host: "repeater.world", protocol: "https")
    repeater.input_country_id = "fi"

    repeater.save!

    repeater
  end

  def import_notes(raw_repeater, repeater)
    repeater.notes = [
      raw_repeater["site_desc"],
      raw_repeater["stdesc"],
      "Responsible club: #{raw_repeater["responsible_club"]} #{raw_repeater["responsible_club_url"]}",
      raw_repeater["remarks"],
      "Last modified #{raw_repeater["last_modified"]}",
      repeater.tetra? ? "Access #{raw_repeater["rep_access"]}." : nil
    ].compact.join("\n\n")
  end

  def import_rx_frequency(raw_repeater, repeater)
    repeater.rx_frequency = if raw_repeater["rep_shift"].blank?
      repeater.tx_frequency
    else
      repeater.tx_frequency + raw_repeater["rep_shift"].to_f * 10**6
    end
  end

  def import_access_method(raw_repeater, repeater)
    if raw_repeater["rep_access"]&.strip&.in? ["Tone 1750", "Tone 1750 tai DTMF *", "Tone 1750, DTMF *", "1750Hz Tone", "Tone 1750, DTMF*", "tone 1750"]
      repeater.fm_tone_burst = true
    elsif raw_repeater["rep_access"]&.strip&.in? ["CTCSS 103.5 Hz", "CTCSS 103,5 Hz", "CTCSS 103,5", "103.5 Hz", "CTCSS 103,5 / Yaesu", "CTCSS 103,5Hz"]
      repeater.fm_ctcss_tone = 103.5
    elsif raw_repeater["rep_access"]&.strip&.in? ["CTCSS 110.9 Hz", "CTCSS 110,9 Hz", "CTCSS 110.9", "ctcss 110.9hz", "CTCSS 110,9", "CTSS 110.9", "CC1 / CTCSS 110.9"]
      repeater.fm_ctcss_tone = 110.9
    elsif raw_repeater["rep_access"]&.strip&.in? ["CTCSS 114.8", "114.8 Hz"]
      repeater.fm_ctcss_tone = 114.8
    elsif raw_repeater["rep_access"]&.strip&.in? ["CTCSS 118.8", "CTCSS 118.8 / NAC293", "118.8", "CTCSS 118.8 Hz"]
      repeater.fm_ctcss_tone = 118.8
    elsif raw_repeater["rep_access"]&.strip&.in? ["CTCSS 123.0"]
      repeater.fm_ctcss_tone = 123.0
    elsif raw_repeater["rep_access"]&.strip&.in? ["CC1", "CC 1"]
      repeater.dmr_color_code = 1 # Just guessing here.
    elsif raw_repeater["rep_access"]&.strip&.in? ["1750 or 118.8", "Tone 1750/CTCSS 118"]
      repeater.fm_tone_burst = true
      repeater.fm_ctcss_tone = 118.8
    elsif raw_repeater["rep_access"]&.strip&.in? ["CC1 / CTCSS 103.5Hz"]
      repeater.fm_ctcss_tone = 103.5
      repeater.dmr_color_code = 1
    elsif raw_repeater["rep_access"]&.strip&.in? ["CC1 / CTCSS 118.8Hz"]
      repeater.fm_ctcss_tone = 118.8
      repeater.dmr_color_code = 1
    elsif raw_repeater["rep_access"]&.strip&.in? ["CC1 / CTCSS 123.0Hz"]
      repeater.fm_ctcss_tone = 123.0
      repeater.dmr_color_code = 1
    elsif raw_repeater["rep_access"]&.strip&.in? ["CC1, CTCSS 118.8Hz"]
      repeater.fm_ctcss_tone = 118.8
      repeater.dmr_color_code = 1
    elsif raw_repeater["rep_access"]&.strip&.in? ["MCC901/MNC9999"]
      # Nothing to do, this is the Tetra repeater (there's literally 1 in Finland so far), not being properly handled yet.
    elsif raw_repeater["rep_access"].blank?
      # Nothing to do.
    else
      raise "Unknown rep_access: \"#{raw_repeater["rep_access"]}\"."
    end
  end

  def import_rx_antenna_polarization(raw_repeater, repeater)
    if raw_repeater["rx_antpol"] == "H"
      repeater.rx_antenna_polarization = "horizontal"
    elsif raw_repeater["rx_antpol"] == "V"
      repeater.rx_antenna_polarization = "vertical"
    end
  end

  def import_tx_antenna_polarization(raw_repeater, repeater)
    if raw_repeater["tx_antpol"] == "H"
      repeater.tx_antenna_polarization = "horizontal"
    elsif raw_repeater["tx_antpol"] == "V"
      repeater.tx_antenna_polarization = "vertical"
    end
  end

  def import_name(raw_repeater, repeater)
    repeater.name = raw_repeater["name"].strip
  end

  def import_mode(raw_repeater, repeater)
    # When a repeater changes mode, the old modes that are no longer there shouldn't remain set to true.
    repeater.disable_all_modes

    if raw_repeater["mode"] == "FM"
      repeater.fm = true
    elsif raw_repeater["mode"] == "NFM"
      repeater.fm = true
      repeater.bandwidth = Repeater::FM_NARROW
    elsif raw_repeater["mode"] == "FM / P25"
      repeater.fm = true
      repeater.p25 = true
    elsif raw_repeater["mode"].in? ["FM / Yaesu", "FM C4FM", "FM / C4FM"]
      repeater.fm = true
      repeater.fusion = true
    elsif raw_repeater["mode"].in? ["DMR, FM", "FM/DMR"]
      repeater.fm = true
      repeater.dmr = true
    elsif raw_repeater["mode"] == "DMR"
      repeater.dmr = true
    elsif raw_repeater["mode"].in? ["TETRA", "TETRA TMO"]
      repeater.tetra = true
    elsif raw_repeater["mode"].blank?
      # Nothing to do.
    elsif raw_repeater["mode"] == "FM, Digi" && repeater.call_sign == "OH4RUB"
      # "FM, Digi" is not used for any other repeater, and the comment in this repeater says it supports these
      # modes.
      repeater.fm = true
      repeater.dstar = true
      repeater.fusion = true
      repeater.dmr = true
    elsif raw_repeater["mode"] == "4FSK" && repeater.call_sign.in?(["OH5DMRA", "OH5RUA", "OH5RUG"])
      # Comments on the repeater information says it's actually DMR.
      repeater.dmr = true
    elsif raw_repeater["mode"] == "Multi" && repeater.call_sign == "OH2RUP"
      # Guessing from the comments
      repeater.fm = true
      repeater.dmr = true
    else
      raise "Unknown mode #{raw_repeater["mode"].inspect}."
    end

    if repeater.dmr?
      if raw_repeater["remarks"].present? &&
          (raw_repeater["remarks"].include?("Brandmeister") ||
            raw_repeater["remarks"].include?("FinDMR")) # Is this correct?
        repeater.dmr_network = "Brandmeister"
      end
    end
  end

  def import_status(raw_repeater, repeater)
    if raw_repeater["status"].in? ["QRV", "EVENT"]
      repeater.operational = true
    elsif raw_repeater["status"] == "QRT"
      repeater.operational = false
    else
      raise "Unknown status: #{raw_repeater["status"]}"
    end
  end
end
