class UkrepeatersImporter
  def import
    # download_all_files

    voice_repeater_list = CSV.table("./tmp/ukrepeaters/voice_repeater_list.csv")
    assert_fields(voice_repeater_list, [:repeater, :band, :channel, :tx, :rx, :mode, :qthr, :where, :region, :code, :keeper, :lat, :lon, nil])

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
    end
  end

  def assert_fields(table, fields)
    if table.headers != fields
      raise "The fields for voice_repeater_list.csv changed, so we can't process it.\n  Expected: #{fields.inspect}\n  Received: #{voice_repeater_list.headers.inspect}"
    end
  end
end
