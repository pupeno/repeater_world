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

class SralfiImporter < Importer
  SOURCE = "https://automatic.sral.fi/?p=export"
  EXPORT_URL = "https://automatic.sral.fi/api-v1.php?query=list"

  def import
    @logger.info "Importing repeaters from #{SOURCE}."
    file_name = download_file(EXPORT_URL, "sralfi_export.json")
    stations = JSON.parse(File.read(file_name))

    ignored_due_to_source_count = 0
    created_or_updated_ids = []
    repeaters_deleted_count = 0

    Repeater.transaction do
      stations["stations"].each do |raw_repeater|
        # Types:
        # 1: Voice repeater,
        # 2: Beacon,
        # 3: APRS digipeater,
        # 4: ATV repeater,
        # 5: Data networks.
        # https://m.pablofernandez.tech/@oh8hub@mastodon.radio/110406906005017761
        # TODO: decide whether to add anything other than voice repeaters.
        if raw_repeater["type"] == "1"
          action, imported_repeater = import_repeater(raw_repeater)
          if action == :ignored_due_to_source
            ignored_due_to_source_count += 1
          else
            created_or_updated_ids << imported_repeater.id
          end
        end
      end
      repeaters_deleted_count = Repeater.where(source: SOURCE).where.not(id: created_or_updated_ids).delete_all
    end

    @logger.info "Done importing from #{SOURCE}. #{created_or_updated_ids.count} created or updated, #{ignored_due_to_source_count} ignored due to source, #{repeaters_deleted_count} deleted."
  end

  private

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

  private

  def import_repeater(raw_repeater)
    repeater = Repeater.find_or_initialize_by(
      call_sign: raw_repeater["callsign"].upcase,
      tx_frequency: raw_repeater["tx_freq"].to_f * 10**6
    )

    # Only update repeaters that were sourced from automatic.sral.fi.
    if repeater.persisted? && repeater.source != SOURCE
      @logger.info "Not updating #{repeater} since the source is #{repeater.source.inspect} and not #{SOURCE.inspect}"
      return [:ignored_due_to_source, repeater]
    end

    repeater.external_id = raw_repeater["id"]
    import_status(raw_repeater, repeater)
    import_mode(raw_repeater, repeater)
    import_name(raw_repeater, repeater)
    repeater.web_site = raw_repeater["station_url"] || raw_repeater["responsible_club_url"]
    # stdesc imported later
    # TODO: what is cwid? It has some of these values: VJ, RI, KT, KA, JA, JY, JM, KO, OU, RO.
    repeater.locality = raw_repeater["qth_city"]
    repeater.grid_square = raw_repeater["locator"]
    repeater.latitude = raw_repeater["wgs84lat"]
    repeater.longitude = raw_repeater["wgs84lon"]
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

    repeater.source = SOURCE
    repeater.redistribution_limitations = data_limitations_sral_fi_url(host: "repeater.world", protocol: "https")
    repeater.country_id = "fi"

    repeater.save!

    [:created_or_updated, repeater]
  rescue => e
    @logger.error "Failed to import repeater #{raw_repeater["callsign"]}: #{e.message}"
    @logger.error raw_repeater
    raise "Failed to import repeater #{raw_repeater}"
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
    elsif raw_repeater["rep_access"]&.strip&.in? ["CTCSS 110.9 Hz", "CTCSS 110,9 Hz", "CTCSS 110.9", "ctcss 110.9hz", "CTCSS 110,9", "CTSS 110.9"]
      repeater.fm_ctcss_tone = 110.9
    elsif raw_repeater["rep_access"]&.strip&.in? ["CTCSS 114.8"]
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
      repeater.dmr_color_code = 1 # Just guessing here.
    elsif raw_repeater["rep_access"]&.strip&.in? ["CC1 / CTCSS 118.8Hz"]
      repeater.fm_ctcss_tone = 118.8
      repeater.dmr_color_code = 1 # Just guessing here.
    elsif raw_repeater["rep_access"]&.strip&.in? ["CC1 / CTCSS 123.0Hz"]
      repeater.fm_ctcss_tone = 123.0
      repeater.dmr_color_code = 1 # Just guessing here.
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
    repeater.name = raw_repeater["name"]&.strip
    repeater.name = raw_repeater["qth_city"]&.strip if repeater.name.blank?
    repeater.name = raw_repeater["callsign"]&.upcase&.strip if repeater.name.blank?
  end

  def import_mode(raw_repeater, repeater)
    if raw_repeater["mode"] == "FM"
      repeater.fm = true
    elsif raw_repeater["mode"] == "NFM"
      repeater.fm = true
      repeater.fm_bandwidth = Repeater::FM_NARROW
    elsif raw_repeater["mode"] == "FM / P25"
      repeater.fm = true
      repeater.p25 = true
    elsif raw_repeater["mode"].in? ["FM / Yaesu", "FM C4FM", "FM / C4FM"]
      repeater.fm = true
      repeater.fusion = true
    elsif raw_repeater["mode"].in? ["DMR, FM", "FM/DMR"]
      repeater.fm = true
      repeater.dmr = true
    elsif raw_repeater["mode"].in? ["FM,DMR,D-S"] # I'm assuming D-S is D-Star.
      repeater.fm = true
      repeater.dstar = true
      repeater.dmr = true
    elsif raw_repeater["mode"] == "DMR"
      repeater.dmr = true
    elsif raw_repeater["mode"] == "TETRA"
      repeater.tetra = true
    elsif raw_repeater["mode"].blank?
      # Nothing to do.
    elsif raw_repeater["mode"] == "FM, Digi" && raw_repeater["callsign"] == "OH4RUB"
      # "FM, Digi" is not used for any other repeater, and the comment in this repeater says it supports these
      # modes.
      repeater.fm = true
      repeater.dstar = true
      repeater.fusion = true
      repeater.dmr = true
    elsif raw_repeater["mode"] == "4FSK" && raw_repeater["callsign"].in?(["OH5DMRA", "OH5RUA", "OH5RUG"])
      # Comments on the repeater information says it's actually DMR.
      repeater.dmr = true
    else
      raise "Unknown mode \"#{raw_repeater["mode"]}\"."
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
    if raw_repeater["status"] == "QRV"
      repeater.operational = true
    elsif raw_repeater["status"] == "QRT"
      repeater.operational = true
    else
      raise "Unknown status: #{raw_repeater["status"]}"
    end
  end
end
