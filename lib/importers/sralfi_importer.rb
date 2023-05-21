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
    Repeater.transaction do
      @logger.info "Importing repeaters from #{SOURCE}."
      file_name = download_file(EXPORT_URL, "sralfi_export.json")
      stations = JSON.parse(File.read(file_name))
      count = 0
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
          import_repeater(raw_repeater)
          count += 1
        end
      end
      @logger.info "Done importing #{count} repeaters from #{SOURCE}."
    end
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
    puts raw_repeater
    repeater = Repeater.find_or_initialize_by(call_sign: raw_repeater["callsign"].upcase)
    repeater.external_id = raw_repeater[:id]
    if raw_repeater["status"] == "QRV"
      repeater.operational = true
    elsif raw_repeater["status"] == "QRT"
      repeater.operational = true
    else
      raise "Unknown status: #{raw_repeater["status"]}"
    end
    if raw_repeater["mode"].in? ["FM", "NFM"] # TODO: do we need to separate narrowband fm into its own mode?
      repeater.fm = true
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
    repeater.name = raw_repeater["name"]
    repeater.name = raw_repeater["qth_city"] if repeater.name.blank?
    repeater.name = raw_repeater["callsign"].upcase if repeater.name.blank?
    repeater.web_site = raw_repeater["station_url"] || raw_repeater["responsible_club_url"]
    # stdesc imported later
    # TODO: what is cwid?
    repeater.locality = raw_repeater["qth_city"]
    repeater.grid_square = raw_repeater["locator"]
    repeater.latitude = raw_repeater["wgs84lat"]
    repeater.longitude = raw_repeater["wgs84lon"]
    # site_desc imported later
    repeater.altitude_asl = raw_repeater["alt_asl"]
    repeater.altitude_agl = raw_repeater["alt_agl"]
    repeater.tx_frequency = raw_repeater["tx_freq"].to_f * 10 ** 6
    repeater.tx_power = raw_repeater["tx_power"]
    repeater.tx_antenna = raw_repeater["tx_ant"]
    if raw_repeater["tx_antpol"] == "H"
      repeater.tx_antenna_polarization = "horizontal"
    elsif raw_repeater["tx_antpol"] == "V"
      repeater.tx_antenna_polarization = "vertical"
    end
    # TODO: what is qtf?
    repeater.rx_antenna = raw_repeater["rx_antenna"]
    if raw_repeater["rx_antpol"] == "H"
      repeater.rx_antenna_polarization = "horizontal"
    elsif raw_repeater["rx_antpol"] == "V"
      repeater.rx_antenna_polarization = "vertical"
    end
    # TODO: what is rep_access?
    repeater.rx_frequency = if raw_repeater["rep_shift"].blank?
                              repeater.tx_frequency
                            else
                              repeater.tx_frequency + raw_repeater["rep_shift"].to_f * 10 ** 6
                            end

    repeater.band = BAND_MAPPING[raw_repeater["band_name"].strip] || raise("Unknown band #{raw_repeater["band_name"]}")
    repeater.keeper = raw_repeater["responsible_club"]
    # responsible_club_url imported earlier/later
    # remarks imported later

    repeater.notes = [
      raw_repeater["site_desc"],
      raw_repeater["stdesc"],
      "Responsible club: #{raw_repeater["responsible_club"]} #{raw_repeater["responsible_club_url"]}",
      raw_repeater["remarks"],
      "Last modified #{raw_repeater["last_modified"]}"
    ].compact.join("\n\n")

    repeater.country_id = "fi"

    if repeater.new_record?
      @logger.info "Creating #{repeater}."
    elsif repeater.changed?
      @logger.info "Updating #{repeater}."
    end

    repeater.save!
  rescue => e
    @logger.error "Failed to import repeater #{raw_repeater["callsign"]}: #{e.message}"
    @logger.error raw_repeater
    raise "Failed to import repeater #{raw_repeater}"
  end
end
