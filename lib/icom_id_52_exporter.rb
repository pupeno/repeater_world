class IcomId52Exporter < Exporter
  def export
    CSV.generate do |csv|
      csv << ["Group No", "Group Name", "Name", "Sub Name", "Repeater Call Sign", "Gateway Call Sign", "Frequency",
              "Dup", "Offset", "Mode", "TONE", "Repeater Tone", "RPT1USE", "Position", "Latitude", "Longitude",
              "UTC Offset"]
      @repeaters
        .where(band: [Repeater::BAND_2M, Repeater::BAND_70CM], # ID-52 can only do VHF and UHF.
               access_method: [Repeater::TONE_BURST, Repeater::CTCSS]) # TODO: can repeaters have no access method?
        .where.not(operational: false) # Skip repeaters known to not be operational.
        .where(fm: true).or(Repeater.where(dstar: true)) # ID-52 does FM and DStar only
        .order(:name)
        .each do |repeater|
        if [Repeater::BAND_2M, Repeater::BAND_70CM].include? repeater.band
          csv << if repeater.fm?
                   fm_repeater(repeater)
                 elsif repeater.dstar?
                   dstar_repeater(repeater)
                 end
        end
      end
    end
  end

  private

  # Max lengths for each field is defined on page iv of the Icom ID-52 Advance Manual
  MAX_COUNTRY_NAME_LENGTH = 16
  MAX_NAME_LENGTH = 16
  MAX_SUB_NAME_LENGTH = 8
  MAX_CALL_SIGN_LENGTH = 8
  MAX_GATEWAY_CALL_SIGN_LENGTH = 8

  def fm_repeater(repeater)
    group_name = repeater.country&.name&.truncate(MAX_COUNTRY_NAME_LENGTH, omission: "")  # TODO: do something smarter about groups.
    name = repeater.name.truncate(MAX_NAME_LENGTH, omission: "")

    call_sign = repeater.call_sign.truncate(MAX_CALL_SIGN_LENGTH, omission: "")

    [
      1, # TODO: do something smarter about groups.
      group_name,
      name,
      nil, # TODO: what's this?
      call_sign,
      nil, # FM repeaters don't have a gateway.
      "%.6f" % (repeater.tx_frequency.to_f / 10 ** 6),
      repeater.tx_frequency > repeater.rx_frequency ? "DUP-" : "DUP+",
      "%.6f" % ((repeater.tx_frequency - repeater.rx_frequency).to_f / 10 ** 6),
      "FM",
      case repeater.access_method
        when Repeater::TONE_BURST
          "OFF"
        when Repeater::CTCSS
          "TONE" # TODO: when do we use TSQL
      end,
      "#{repeater.ctcss_tone}Hz",
      "Yes", # TODO: what is this?
      "Approximate", # TODO: why does the export have some "Exacts"
      repeater.latitude,
      repeater.longitude,
      "--:--" # TODO: export UTC Offset.
    ]
  end

  # Max lengths for each field is defined on page iv of the Icom ID-52 Advance Manual
  def dstar_repeater(repeater)
    group_name = repeater.country&.name&.truncate(MAX_COUNTRY_NAME_LENGTH, omission: "")  # TODO: do something smarter about groups.
    name = repeater.name.truncate(MAX_NAME_LENGTH, omission: "")

    call_sign = add_dstar_port(repeater.call_sign, conventional_dstar_port(repeater.band, repeater.country&.id))
                  .truncate(MAX_CALL_SIGN_LENGTH, omission: "")
    gateway_call_sign = add_dstar_port(repeater.call_sign, "G") # Always "G" according to page 5-30 of the ID-52 Advanced manual
                          .truncate(MAX_GATEWAY_CALL_SIGN_LENGTH, omission: "")

    [
      1, # TODO: do something smarter about groups.
      group_name,
      name,
      nil, # TODO: what's this?
      call_sign,
      gateway_call_sign,
      "%.6f" % (repeater.tx_frequency.to_f / 10 ** 6),
      repeater.tx_frequency > repeater.rx_frequency ? "DUP-" : "DUP+",
      "%.6f" % ((repeater.tx_frequency - repeater.rx_frequency).to_f / 10 ** 6),
      "DV",
      nil, # No access method in D-Star,
      nil, # No access method in D-Star,
      "Yes", # TODO: what is this?
      "Approximate", # TODO: why does the export have some "Exacts"
      repeater.latitude,
      repeater.longitude,
      "--:--" # TODO: export UTC Offset.
    ]
  end

end
