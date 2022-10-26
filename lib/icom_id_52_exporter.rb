class IcomId52Exporter < Exporter
  def export
    CSV.generate do |csv|
      csv << ["Group No", "Group Name", "Name", "Sub Name", "Repeater Call Sign", "Gateway Call Sign", "Frequency",
              "Dup", "Offset", "Mode", "TONE", "Repeater Tone", "RPT1USE", "Position", "Latitude", "Longitude",
              "UTC Offset"]
      @repeaters.each do |repeater|
        if [Repeater::BAND_2M, Repeater::BAND_70CM].include? repeater.band
          if repeater.fm?
            csv << [1, # TODO: do something smarter about groups.
                    repeater.country&.name, # TODO: do something smarter about groups.
                    repeater.name,
                    "", # TODO: what's this?
                    repeater.call_sign,
                    "", # TODO: what's this?
                    repeater.tx_frequency.to_f / 10 ** 6,
                    repeater.tx_frequency > repeater.rx_frequency ? "DUP-" : "DUP+",
                    (repeater.tx_frequency - repeater.rx_frequency).to_f / 10 ** 6,
                    "FM",
                    case repeater.access_method
                      when Repeater::TONE_BURST
                        "OFF"
                      when Repeater::CTCSS
                        "TONE" # TODO: when do we use TSQL
                      else
                        raise "Unknown access method for #{repeater}: #{repeater.access_method}"
                    end,
                    "#{repeater.ctcss_tone}Hz",
                    "Yes", # TODO: what is this?
                    "Approximate", # TODO: why does the export have some "Exacts"
                    repeater.latitude,
                    repeater.longitude,
                    "--:--" # TODO: export UTC Offset.
            ]
          end
        end
      end
    end
  end
end
