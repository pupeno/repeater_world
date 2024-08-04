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

require "open-uri"

class UkrepeatersImporter < Importer
  def self.source
    "https://ukrepeater.net"
  end

  private

  def import_all_repeaters
    repeaters = process_repeaterlist3_csv({})
    repeaters = process_repeaterlist_dv_csv(repeaters)
    repeaters = process_repeaterlist_all_csv(repeaters)
    repeaters = process_repeaterlist_alt2_csv(repeaters)
    # TODO: process packetlist: https://ukrepeater.net/csvfiles.html https://ukrepeater.net/csvcreate4.php
    repeaters = process_repeaterlist_status_csv(repeaters)

    repeaters.values.each_with_index do |raw_repeater, index|
      yield(raw_repeater, index)
    end
  end

  def call_sign_and_tx_frequency(raw_repeater)
    [raw_repeater[:call_sign].upcase, raw_repeater[:tx_frequency]]
  end

  def import_repeater(raw_repeater, repeater)
    # When a repeater changes mode, the old modes that are no longer there shouldn't remain set to true.
    repeater.disable_all_modes
    repeater.assign_attributes(raw_repeater)
    repeater.save!
    repeater
  end

  def process_repeaterlist3_csv(repeaters)
    file_name = download_file("https://ukrepeater.net/csvcreate3.php", "repeaterlist3.csv")
    csv_file = CSV.table(file_name)
    assert_fields(csv_file, [:callsign, :band, :channel, :tx, :rx, :modes, :qthr, :ngr, :where, :postcode, :region, :ctcsscc, :keeper, :lat, :lon, nil], "https://ukrepeater.net/csvcreate3.php", file_name)

    csv_file.each_with_index do |row, line_number|
      raw_repeater = {call_sign: parse_call_sign(row[:callsign]),
                      tx_frequency: parse_frequency(row[:tx])}

      # Some metadata.
      raw_repeater[:name] = row[:where].titleize
      raw_repeater[:band] = row[:band]&.downcase
      raw_repeater[:channel] = row[:channel]
      raw_repeater[:keeper] = row[:keeper]

      # How to access the repeater.
      raw_repeater[:rx_frequency] = row[:rx].to_f * 10**6
      if row[:ctcsscc].present?
        if Repeater::CTCSS_TONES.include?(row[:ctcsscc].to_f)
          raw_repeater[:fm_ctcss_tone] = row[:ctcsscc]
          raw_repeater[:fm_tone_squelch] = false # TODO: how do we know when this should be true? https://github.com/pupeno/repeater_world/issues/23
        elsif Repeater::DMR_COLOR_CODES.include?(row[:ctcsscc].to_f)
          raw_repeater[:dmr_color_code] = row[:ctcsscc]
        end
      end

      # The location of the repeater
      raw_repeater[:input_grid_square] = row[:qthr].upcase
      raw_repeater[:input_latitude] = row[:lat]
      raw_repeater[:input_longitude] = row[:lon]
      raw_repeater[:input_locality] = row[:where].titleize
      case row[:region]
      when "SE"
        raw_repeater[:input_region] = "South East, England"
      when "SW"
        raw_repeater[:input_region] = "South West, England"
      when "NOR"
        raw_repeater[:input_region] = "North England"
      when "SCOT"
        raw_repeater[:input_region] = "Scotland"
      when "WM"
        raw_repeater[:input_region] = "Wales & Marches"
      when "NI"
        raw_repeater[:input_region] = "Northern Ireland"
      when "CEN"
        raw_repeater[:input_region] = "Central England"
      when "EA"
        raw_repeater[:input_region] = "East of England & East Anglia"
      when "XXX"
        raw_repeater[:input_region] = nil
      else
        raise "Unknown region #{row[:region]} for repeater #{row}"
      end
      raw_repeater[:input_post_code] = row[:postcode]
      raw_repeater[:input_country_id] = "gb"

      raw_repeater[:source] = self.class.source
      raw_repeater[:redistribution_limitations] = data_limitations_ukrepeater_net_url(host: "repeater.world", protocol: "https")

      repeaters["#{raw_repeater[:call_sign]} #{raw_repeater[:tx_frequency]}"] = raw_repeater
    end

    repeaters
  end

  def process_repeaterlist_dv_csv(repeaters)
    file_name = download_file("https://ukrepeater.net/csvcreate_dv.php", "repeaterlist_dv.csv")
    csv_file = CSV.table(file_name)
    assert_fields(csv_file, [:call, :band, :chan, :txmhz, :rxmhz, :ctcss, :reg, :netw, :col, :qthr, :ngr, :where, :dmr, :dstar, :fusion, :nxdn, nil], "https://ukrepeater.net/csvcreate_dv.php", file_name)

    csv_file.each do |row|
      raw_repeater = repeaters["#{parse_call_sign(row[:call])} #{parse_frequency(row[:txmhz])}"]
      if raw_repeater.blank?
        @ignored_due_to_invalid_count += 1
        next
      end

      # We set them to true if "Y", we leave them as NULL otherwise. Let's not assume false when we don't have info.
      raw_repeater[:dmr] = true if row[:dmr]&.strip == "Y"
      raw_repeater[:dstar] = true if row[:dstar]&.strip == "Y"
      raw_repeater[:fusion] = true if row[:fusion]&.strip == "Y"
      raw_repeater[:nxdn] = true if row[:nxdn]&.strip == "Y"
    end

    repeaters
  end

  def process_repeaterlist_all_csv(repeaters)
    file_name = download_file("https://ukrepeater.net/csvcreate_all.php", "repeaterlist_all.csv")
    csv_file = CSV.table(file_name)
    assert_fields(csv_file, [:call, :band, :chan, :txmhz, :rxmhz, :ctcss, :qthr, :ngr, :where, :analog, :dmr, :dstar, :fusion, nil], "https://ukrepeater.net/csvcreate_all.php", file_name)

    csv_file.each do |row|
      raw_repeater = repeaters["#{parse_call_sign(row[:call])} #{parse_frequency(row[:txmhz])}"]
      if raw_repeater.blank?
        @ignored_due_to_invalid_count += 1
        next
      end

      # We set them to true if "Y", we leave them as NULL otherwise. Let's not assume false when we don't have info.
      raw_repeater[:fm] = true if row[:analog]&.strip == "Y"
      if raw_repeater[:fm] && row[:ctcss].present? # This file contains some improvements on CTCSS code.
        raw_repeater[:fm_ctcss_tone] = row[:ctcss]
      end

      raw_repeater[:dstar] = true if row[:dstar]&.strip == "Y"

      raw_repeater[:fusion] = true if row[:fusion]&.strip == "Y"

      raw_repeater[:dmr] = true if row[:dmr]&.strip == "Y"
    end

    repeaters
  end

  def process_repeaterlist_alt2_csv(repeaters)
    file_name = download_file("https://ukrepeater.net/repeaterlist-alt.php", "repeaterlist_alt2.csv")
    csv_file = CSV.table(file_name)
    assert_fields(csv_file, [:call, :band, :chan, :txmhz, :rxmhz, :shift, :qthr, :ngr, :where, :reg, :ctcss, :dmrcc, :dmrcon, :lat, :lon, :status, :analg, :dmr, :dstar, :fusion, :nxdn, nil], "https://ukrepeater.net/repeaterlist-alt.php", file_name)

    csv_file.each do |row|
      raw_repeater = repeaters["#{parse_call_sign(row[:call])} #{parse_frequency(row[:txmhz])}"]
      if raw_repeater.blank?
        @ignored_due_to_invalid_count += 1
        next
      end

      raw_repeater[:fm] = row[:analg] == 1

      raw_repeater[:dstar] = row[:dstar] == 1

      raw_repeater[:fusion] = row[:fusion] == 1

      raw_repeater[:dmr] = row[:dmr] == 1
      raw_repeater[:dmr_color_code] = row[:dmrcc]
      raw_repeater[:dmr_network] = row[:dmrcon]

      parse_operational(row, raw_repeater)
    end

    repeaters
  end

  def process_repeaterlist_status_csv(repeaters)
    file_name = download_file("https://ukrepeater.net/csvcreatewithstatus.php", "repeaterlist_status.csv")
    csv_file = CSV.table(file_name)
    assert_fields(csv_file, [:repeater, :band, :channel, :tx, :rx, :modes, :qthr, :ngr, :where, :region, :ctcsscc, :keeper, :status, nil], "https://ukrepeater.net/csvcreatewithstatus.php", file_name)

    csv_file.each do |row|
      raw_repeater = repeaters["#{parse_call_sign(row[:repeater])} #{parse_frequency(row[:tx])}"]
      if raw_repeater.blank?
        @ignored_due_to_invalid_count += 1
        next
      end

      parse_operational(row, raw_repeater)
    end

    repeaters
  end

  def parse_call_sign(call_sign)
    call_sign.upcase
  end

  def parse_frequency(frequency)
    (frequency.to_f * 10**6).to_i
  end

  def parse_operational(raw_repeater, repeater)
    if raw_repeater[:status] == "OPERATIONAL"
      repeater[:operational] = true
    elsif raw_repeater[:status] == "REDUCED OUTPUT"
      repeater[:operational] = true
      repeater[:notes] = "Reduced output."
    elsif raw_repeater[:status] == "DMR ONLY"
      repeater[:operational] = true
      repeater[:notes] = "DMR only."
    elsif raw_repeater[:status] == "NOT OPERATIONAL" ||
        raw_repeater[:status] == "CLOSED DOWN"
      repeater[:operational] = false
    elsif raw_repeater[:status].blank?
      repeater[:operational] = nil
    else
      raise "Unknown status #{raw_repeater[:status].inspect}"
    end
  end

  def assert_fields(table, fields, url, file_name)
    if table.headers != fields
      raise "The fields for #{url} changed, so we can't process it.\n  Expected: #{fields.inspect}\n  Received: #{table.headers.inspect}\n  Local file: #{file_name}"
    end
  end
end
