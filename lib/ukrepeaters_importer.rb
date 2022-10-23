class UkrepeatersImporter
  def import
    # TODO: uncomment this
    files = download_all_files

    Repeater.transaction do

      puts "Creating repeaters from voice_repeaters_including_gateways.csv..."
      voice_repeaters_ig = CSV.table(files[:voice_repeaters_including_gateways][:local_file_name])
      assert_fields(files[:voice_repeaters_including_gateways], voice_repeaters_ig, [:callsign, :band, :channel, :tx, :rx, :mode, :qthr, :where, :postcode, :region, :code, :keeper, :lat, :lon, nil])
      voice_repeaters_ig.each_with_index do |raw_repeater, line_number|
        create_repeater(raw_repeater)
      rescue
        raise "Failed to import record on #{line_number + 2}: #{raw_repeater.to_s}" # Line numbers start at 1, not 0, and there's a header, hence the +2
      end
      puts "Done creating repeaters."

      puts "Enhancing DV modes..."
      dv_modes_only = CSV.table(files[:dv_modes_only][:local_file_name])
      assert_fields(files[:dv_modes_only], dv_modes_only, [:call, :band, :chan, :txmhz, :rxmhz, :ctcss, :loc, :where, :dmr, :dstar, :fusion, :nxdn, nil])
      dv_modes_only.each_with_index do |raw_repeater, line_number|
        repeater = Repeater.find_by(call_sign: raw_repeater[:call])
        if !repeater
          raise "Couldn't find repeater with call sign #{raw_repeater[:call]}"
        end

        # We set them to true if "Y", we leave them as NULL otherwise. Let's not assume false when we don't have info.
        repeater.dmr = true if raw_repeater[:dmr]&.strip == "Y"
        repeater.dstar = true if raw_repeater[:dstar]&.strip == "Y"
        repeater.fusion = true if raw_repeater[:fusion]&.strip == "Y"
        repeater.nxdn = true if raw_repeater[:nxdn]&.strip == "Y"

        puts "  Enhanced #{repeater}."
        repeater.save!
      rescue
        raise "Failed to import record on #{line_number + 2}: #{raw_repeater.to_s}" # Line numbers start at 1, not 0, and there's a header, hence the +2
      end
      puts "Done enhancing DV modes."
    end
  end

  private

  # Create repeater from a record in voice_repeater_list.csv
  def create_repeater(raw_repeater)
    # For the UK, we treat the call sign as unique and the identifier of the repeater.
    repeater = Repeater.find_or_initialize_by(call_sign: raw_repeater[:callsign].upcase)
    already_existed = !repeater.new_record?

    # Some metadata.
    repeater.name = "#{raw_repeater[:where].titleize} #{repeater.call_sign}"
    repeater.band = raw_repeater[:band].downcase
    repeater.channel = raw_repeater[:channel]
    repeater.keeper = raw_repeater[:keeper]

    # How to access the repeater.
    repeater.tx_frequency = raw_repeater[:tx].to_f * 10 ** 6
    repeater.rx_frequency = raw_repeater[:rx].to_f * 10 ** 6
    if raw_repeater[:code].present?
      repeater.access_method = Repeater::CTCSS
      repeater.ctcss_tone = raw_repeater[:code]
      repeater.tone_sql = false # TODO: how do we know when this should be true?
    else
      repeater.access_method = Repeater::TONE_BURST
    end

    # The location of the repeater
    repeater.grid_square = raw_repeater[:qthr].upcase
    repeater.latitude = raw_repeater[:lat]
    repeater.longitude = raw_repeater[:lon]
    repeater.country_id = "gb"
    repeater.region_1 = raw_repeater[:region]
    repeater.region_2 = raw_repeater[:postcode]
    repeater.region_3 = raw_repeater[:where].titleize

    repeater.save!

    if already_existed
      puts "  Already existed: #{repeater}"
    else
      puts "  Created #{repeater}."
    end
    repeater
  end

  def download_all_files
    puts "Downloading files..."
    # TODO: use temp file names https://ruby-doc.org/stdlib-2.5.3/libdoc/tempfile/rdoc/Tempfile.html
    result = {}

    # voice_repeaters_including_gateways.csv contains everything voice_repeater_list.csv and
    # alternative_voice_repeater_list.csv plus some more, so we only download voice_repeaters_including_gateways.csv
    # result[:voice_repeater_list] = download_file("https://ukrepeater.net/csvcreate1.php", "./tmp/ukrepeaters/voice_repeater_list.csv")
    # result[:alternative_voice_repeater_list] =  download_file("https://ukrepeater.net/csvcreate2.php", "./tmp/ukrepeaters/alternative_voice_repeater_list.csv")
    result[:voice_repeaters_including_gateways] = download_file("https://ukrepeater.net/csvcreate3.php", "./tmp/ukrepeaters/voice_repeaters_including_gateways.csv")

    result[:dv_modes_only] = download_file("https://ukrepeater.net/csvcreate_dv.php", "./tmp/ukrepeaters/dv_modes_only.csv")
    # download_file("https://ukrepeater.net/csvcreate_all.php", "./tmp/ukrepeaters/all_modes.csv")
    # download_file("https://ukrepeater.net/repeaterlist-alt.php", "./tmp/ukrepeaters/repeaters_up_to_uhf.csv")
    # download_file("https://ukrepeater.net/csvcreate4.php", "./tmp/ukrepeaters/packet_list.csv")
    # download_file("https://ukrepeater.net/csvcreatewithstatus.php", "./tmp/ukrepeaters/voice_repeaters_including_status.csv")
    # download_file("https://ukrepeater.net/csvcreate_beacons.php", "./tmp/ukrepeaters/uk_beacons_including_status.csv")
    # download_file("https://rsgb.online/ukrepeater.kml", "./tmp/ukrepeaters/google_earth_locations.kml")
    puts "Done downloading files."

    result
  end

  def download_file(url, dest)
    if !File.exist?(dest)
      puts "  Downloading #{url}"
      IO.copy_stream(URI.parse(url).open, dest)
    else
      puts "  Already downloaded #{url}"
    end
    { url: url, local_file_name: dest }
  end

  def assert_fields(meta, table, fields)
    if table.headers != fields
      raise "The fields for voice_repeater_list.csv changed, so we can't process it.\n  Expected: #{fields.inspect}\n  Received: #{table.headers.inspect}\n  URL: #{meta[:url]}\n  Local file: #{meta[:local_file_name]}"
    end
  end
end
