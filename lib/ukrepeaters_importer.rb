class UkrepeatersImporter
  def import
    # TODO: uncomment this
    # download_all_files

    voice_repeater_list = CSV.table("./tmp/ukrepeaters/voice_repeater_list.csv")
    assert_fields(voice_repeater_list, [:repeater, :band, :channel, :tx, :rx, :mode, :qthr, :where, :region, :code, :keeper, :lat, :lon, nil])

    puts "Creating repeaters..."
    Repeater.transaction do
      voice_repeater_list.each_with_index do |raw_repeater, line_number|

        # For the UK, we treate the call sign as unique and the identifier of the repeater.
        repeater = Repeater.find_or_initialize_by(call_sign: raw_repeater[:repeater].upcase)

        repeater.name = raw_repeater[:where].titleize
        repeater.band = raw_repeater[:band].downcase
        repeater.channel = raw_repeater[:channel]
        repeater.keeper = raw_repeater[:keeper]

        repeater.tx_frequency = raw_repeater[:tx].to_f * 10 ** 6
        repeater.rx_frequency = raw_repeater[:rx].to_f * 10 ** 6
        if raw_repeater[:code].present?
          repeater.access_method = Repeater::CTCSS
          repeater.ctcss_tone = raw_repeater[:code]
          repeater.tone_sql = false # TODO: how do we know when this should be true?
        else
          repeater.access_method = Repeater::TONE_BURST
        end

        repeater.grid_square = raw_repeater[:qthr].upcase
        repeater.latitude = raw_repeater[:lat]
        repeater.longitude = raw_repeater[:lon]
        repeater.country_id = "gb"
        repeater.region_1 = raw_repeater[:region]

        repeater.save!

        puts "  Created #{repeater}."
      rescue => e
        raise StandardError.new("Failed to import record on #{line_number + 2}: #{raw_repeater.to_s}") # Line numbers start at 1, not 0, and there's a header, hence the +2
      end
    end
    puts "Done creating repeaters."
  end

  private

  def download_all_files
    puts "Downloading files..."
    # TODO: use temp file names https://ruby-doc.org/stdlib-2.5.3/libdoc/tempfile/rdoc/Tempfile.html
    download_file("https://ukrepeater.net/csvcreate1.php", "./tmp/ukrepeaters/voice_repeater_list.csv")
    download_file("https://ukrepeater.net/csvcreate2.php", "./tmp/ukrepeaters/alternative_voice_repeater_list.csv")
    download_file("https://ukrepeater.net/csvcreate3.php", "./tmp/ukrepeaters/voice_repeaters_including_gateways.csv")
    download_file("https://ukrepeater.net/csvcreate_dv.php", "./tmp/ukrepeaters/dv_modes_only.csv")
    download_file("https://ukrepeater.net/csvcreate_all.php", "./tmp/ukrepeaters/all_modes.csv")
    download_file("https://ukrepeater.net/repeaterlist-alt.php", "./tmp/ukrepeaters/repeaters_up_to_uhf.csv")
    download_file("https://ukrepeater.net/csvcreate4.php", "./tmp/ukrepeaters/packet_list.csv")
    download_file("https://ukrepeater.net/csvcreatewithstatus.php", "./tmp/ukrepeaters/voice_repeaters_including_status.csv")
    download_file("https://ukrepeater.net/csvcreate_beacons.php", "./tmp/ukrepeaters/uk_beacons_including_status.csv")
    download_file("https://rsgb.online/ukrepeater.kml", "./tmp/ukrepeaters/google_earth_locations.kml")
    puts "Done downloading files."
  end

  def download_file(url, dest)
    if !File.exist?(dest)
      puts "  Downloading #{url}"
      IO.copy_stream(URI.parse(url).open, dest)
    else
      puts "  Already downloaded #{url}"
    end
  end

  def assert_fields(table, fields)
    if table.headers != fields
      raise "The fields for voice_repeater_list.csv changed, so we can't process it.\n  Expected: #{fields.inspect}\n  Received: #{voice_repeater_list.headers.inspect}"
    end
  end
end
