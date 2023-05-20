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

require "open-uri"

class UkrepeatersImporter
  USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 https://repeater.world/crawler info@repeater.world"
  SOURCE = "https://ukrepeater.net"

  def initialize(working_directory: nil, logger: nil)
    @working_directory = working_directory || Rails.root.join("tmp", "ukrepeaters").to_s # Stable working directory to avoid re-downloading when developing.
    @logger = logger || Rails.logger
  end

  def import
    Repeater.transaction do
      process_repeaterlist3_csv
      process_repeaterlist_dv_csv
      process_repeaterlist_all_csv
      process_repeaterlist_alt2_csv
      # TODO: process packetlist: https://ukrepeater.net/csvfiles.html https://ukrepeater.net/csvcreate4.php
      process_repeaterlist_status_csv
    end
  end

  private

  def process_repeaterlist3_csv
    @logger.info "Processing repeaterlist3.csv..."

    file_name = download_file("https://ukrepeater.net/csvcreate3.php", "repeaterlist3.csv")
    csv_file = CSV.table(file_name)
    assert_fields(csv_file, [:callsign, :band, :channel, :tx, :rx, :modes, :qthr, :where, :postcode, :region, :ctcsscc, :keeper, :lat, :lon, nil], "https://ukrepeater.net/csvcreate3.php", file_name)

    csv_file.each_with_index do |raw_repeater, line_number|
      create_repeater(raw_repeater)
    rescue
      raise "Failed to import record on #{line_number + 2}: #{raw_repeater}" # Line numbers start at 1, not 0, and there's a header, hence the +2
    end
    @logger.info "Done processing repeaterlist3.csv..."
  end

  # Create repeater from a record in voice_repeater_list.csv
  def create_repeater(raw_repeater)
    # For the UK, we treat the call sign as unique and the identifier of the repeater.
    repeater = Repeater.find_or_initialize_by(call_sign: raw_repeater[:callsign].upcase)

    # Only update repeaters that were sourced from ukrepeater.
    if repeater.persisted? && repeater.source != SOURCE
      @logger.info "  Not updating #{repeater} since the source is #{repeater.source.inspect} and not #{SOURCE.inspect}"
      return
    end

    # Some metadata.
    repeater.name = raw_repeater[:where].titleize
    repeater.band = raw_repeater[:band].downcase
    repeater.channel = raw_repeater[:channel]
    repeater.keeper = raw_repeater[:keeper]

    # How to access the repeater.
    repeater.tx_frequency = raw_repeater[:tx].to_f * 10**6
    repeater.rx_frequency = raw_repeater[:rx].to_f * 10**6
    if raw_repeater[:code].present?
      if Repeater::CTCSS_TONES.include?(raw_repeater[:code].to_f)
        repeater.access_method = Repeater::CTCSS
        repeater.ctcss_tone = raw_repeater[:code]
        repeater.tone_sql = false # TODO: how do we know when this should be true? https://github.com/pupeno/repeater_world/issues/23
      elsif Repeater::DMR_COLOR_CODES.include?(raw_repeater[:code].to_f)
        repeater.dmr_color_code = raw_repeater[:code]
      else
        @logger.info "  Ignoring invalid code #{raw_repeater[:code]} in #{raw_repeater}"
      end
      # else
      #   repeater.access_method = Repeater::TONE_BURST
    end

    # The location of the repeater
    repeater.grid_square = raw_repeater[:qthr].upcase
    repeater.latitude = raw_repeater[:lat]
    repeater.longitude = raw_repeater[:lon]
    repeater.locality = raw_repeater[:where].titleize
    case raw_repeater[:region]
    when "SE"
      repeater.region = "South East, England"
    when "SW"
      repeater.region = "South West, England"
    when "NOR"
      repeater.region = "North England"
    when "MIDL"
      repeater.region = "Midlands, England"
    when "SCOT"
      repeater.region = "Scotland"
    when "WM"
      repeater.region = "Wales & Marches"
    when "NI"
      repeater.region = "Northern Ireland"
    when "CEN"
      repeater.region = "Central England"
    else
      raise "Unknown region #{raw_repeater[:region]} for repeater #{raw_repeater}"
    end
    repeater.post_code = raw_repeater[:postcode]
    repeater.country_id = "gb"

    repeater.utc_offset = "0:00"

    repeater.source = SOURCE
    repeater.redistribution_limitations = "https://repeater.world/ukrepeater-net"

    @logger.info "  Created #{repeater}." if repeater.new_record?

    repeater.save!
  end

  def process_repeaterlist_dv_csv
    @logger.info "Processing repeaterlist_dv.csv..."

    file_name = download_file("https://ukrepeater.net/csvcreate_dv.php", "repeaterlist_dv.csv")
    csv_file = CSV.table(file_name)
    assert_fields(csv_file, [:call, :band, :chan, :txmhz, :rxmhz, :ctcss, :loc, :where, :dmr, :dstar, :fusion, :nxdn, nil], "https://ukrepeater.net/csvcreate_dv.php", file_name)

    csv_file.each_with_index do |raw_repeater, line_number|
      repeater = Repeater.find_by(call_sign: raw_repeater[:call])
      if !repeater
        @logger.info "  Repeater not found: #{raw_repeater[:call]} when importing #{raw_repeater}"
        next # TODO: create these repeaters.
      elsif repeater.source != SOURCE
        @logger.info "  Not updating #{repeater} since the source is #{repeater.source.inspect} and not #{SOURCE.inspect}"
        next
      end

      # We set them to true if "Y", we leave them as NULL otherwise. Let's not assume false when we don't have info.
      repeater.dmr = true if raw_repeater[:dmr]&.strip == "Y"
      repeater.dstar = true if raw_repeater[:dstar]&.strip == "Y"
      repeater.fusion = true if raw_repeater[:fusion]&.strip == "Y"
      repeater.nxdn = true if raw_repeater[:nxdn]&.strip == "Y"

      @logger.info "  Enriched #{repeater}." if repeater.changed?

      repeater.save!
    rescue
      raise "Failed to import record on #{line_number + 2}: #{raw_repeater}" # Line numbers start at 1, not 0, and there's a header, hence the +2
    end
    @logger.info "Done processing repeaterlist_dv.csv."
  end

  def process_repeaterlist_all_csv
    @logger.info "Processing repeaterlist_all.csv..."

    file_name = download_file("https://ukrepeater.net/csvcreate_all.php", "repeaterlist_all.csv")
    csv_file = CSV.table(file_name)
    assert_fields(csv_file, [:call, :band, :chan, :txmhz, :rxmhz, :ctcss, :loc, :where, :analog, :dmr, :dstar, :fusion, nil], "https://ukrepeater.net/csvcreate_all.php", file_name)

    csv_file.each_with_index do |raw_repeater, line_number|
      repeater = Repeater.find_by(call_sign: raw_repeater[:call])
      if !repeater
        @logger.info "  Repeater not found: #{raw_repeater[:call]}"
        next # TODO: create these repeaters.
      elsif repeater.source != SOURCE
        @logger.info "  Not updating #{repeater} since the source is #{repeater.source.inspect} and not #{SOURCE.inspect}"
        next
      end

      # We set them to true if "Y", we leave them as NULL otherwise. Let's not assume false when we don't have info.
      repeater.fm = true if raw_repeater[:analog]&.strip == "Y"
      if repeater.fm && raw_repeater[:ctcss].present? # This file contains some improvements on CTCSS code.
        repeater.access_method = Repeater::CTCSS
        repeater.ctcss_tone = raw_repeater[:ctcss]
      end

      repeater.dstar = true if raw_repeater[:dstar]&.strip == "Y"

      repeater.fusion = true if raw_repeater[:fusion]&.strip == "Y"

      repeater.dmr = true if raw_repeater[:dmr]&.strip == "Y"

      @logger.info "  Enriched #{repeater}." if repeater.changed?

      repeater.save!
    rescue
      raise "Failed to import record on #{line_number + 2}: #{raw_repeater}" # Line numbers start at 1, not 0, and there's a header, hence the +2
    end
    @logger.info "Done processing repeaterlist_all.csv."
  end

  def process_repeaterlist_alt2_csv
    @logger.info "Processing repeaterlist_alt2.csv..."

    file_name = download_file("https://ukrepeater.net/repeaterlist-alt.php", "repeaterlist_alt2.csv")
    csv_file = CSV.table(file_name)
    assert_fields(csv_file, [:call, :band, :chan, :txmhz, :rxmhz, :shift, :loc, :where, :reg, :ctcss, :dmrcc, :dmrcon, :lat, :lon, :status, :analg, :dmr, :dstar, :fusion, :nxdn, nil], "https://ukrepeater.net/repeaterlist-alt.php", file_name)

    csv_file.each_with_index do |raw_repeater, line_number|
      repeater = Repeater.find_by(call_sign: raw_repeater[:call])
      if !repeater
        @logger.info "  Repeater not found: #{raw_repeater[:call]}"
        next # TODO: create these repeaters.
      elsif repeater.source != SOURCE
        @logger.info "  Not updating #{repeater} since the source is #{repeater.source.inspect} and not #{SOURCE.inspect}"
        next
      end

      repeater.fm = raw_repeater[:analg] == 1

      repeater.dstar = raw_repeater[:dstar] == 1

      repeater.fusion = raw_repeater[:fusion] == 1

      repeater.dmr = raw_repeater[:dmr] == 1
      repeater.dmr_color_code = raw_repeater[:dmrcc]
      repeater.dmr_network = raw_repeater[:dmrcon]

      if raw_repeater[:status] == "OPERATIONAL"
        repeater.operational = true
      elsif raw_repeater[:status] == "REDUCED OUTPUT"
        repeater.operational = true
        repeater.notes = "Reduced output."
      elsif raw_repeater[:status] == "DMR ONLY"
        repeater.operational = true
        repeater.notes = "DMR only."
      elsif raw_repeater[:status] == "NOT OPERATIONAL"
        repeater.operational = false
      else
        raise "Unknown status #{raw_repeater[:status]}"
      end

      @logger.info "  Enriched #{repeater}." if repeater.changed?

      repeater.save!
    rescue
      raise "Failed to import record on #{line_number + 2}: #{raw_repeater}" # Line numbers start at 1, not 0, and there's a header, hence the +2
    end
    @logger.info "Done processing repeaterlist_alt2.csv."
  end

  def process_repeaterlist_status_csv
    @logger.info "Processing repeaterlist_status.csv..."

    file_name = download_file("https://ukrepeater.net/csvcreatewithstatus.php", "repeaterlist_status.csv")
    csv_file = CSV.table(file_name)
    assert_fields(csv_file, [:repeater, :band, :channel, :tx, :rx, :modes, :qthr, :where, :region, :ctcsscc, :keeper, :status, nil], "https://ukrepeater.net/csvcreatewithstatus.php", file_name)

    csv_file.each_with_index do |raw_repeater, line_number|
      repeater = Repeater.find_by(call_sign: raw_repeater[:repeater])
      if !repeater
        @logger.info "  Repeater not found: #{raw_repeater[:repeater]}"
        next # TODO: create these repeaters.
      elsif repeater.source != SOURCE
        @logger.info "  Not updating #{repeater} since the source is #{repeater.source.inspect} and not #{SOURCE.inspect}"
        next
      end

      if raw_repeater[:status] == "OPERATIONAL"
        repeater.operational = true
      elsif raw_repeater[:status] == "REDUCED OUTPUT"
        repeater.operational = true
        repeater.notes = "Reduced output."
      elsif raw_repeater[:status] == "DMR ONLY"
        repeater.operational = true
        repeater.notes = "DMR only."
      elsif raw_repeater[:status] == "NOT OPERATIONAL"
        repeater.operational = false
      else
        raise "Unknown status #{raw_repeater[:status]}"
      end

      @logger.info "  Enriched #{repeater}." if repeater.changed?

      repeater.save!
    rescue
      raise "Failed to import record on #{line_number + 2}: #{raw_repeater}" # Line numbers start at 1, not 0, and there's a header, hence the +2
    end
    @logger.info "Done processing repeaterlist_status.csv."
  end

  def download_file(url, dest)
    dest = File.join(@working_directory, dest)
    if !File.exist?(dest)
      @logger.info "  Downloading #{url}"
      dirname = File.dirname(dest)
      FileUtils.mkdir_p(dirname) if !File.directory?(dirname)
      src_stream = URI.parse(url).open({"User-Agent" => USER_AGENT})
      IO.copy_stream(src_stream, dest)
    end

    dest
  end

  def assert_fields(table, fields, url, file_name)
    if table.headers != fields
      raise "The fields for #{url} changed, so we can't process it.\n  Expected: #{fields.inspect}\n  Received: #{table.headers.inspect}\n  Local file: #{file_name}"
    end
  end
end
