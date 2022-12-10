# Hopefully when we add more exporters, this class will get a better name.
class IcomExporter < Exporter
  def export
    headers = ["Group No", "Group Name", "Name", "Sub Name", "Repeater Call Sign", "Gateway Call Sign", "Frequency", "Dup", "Offset", "Mode", "TONE", "Repeater Tone", "RPT1USE", "Position", "Latitude", "Longitude", "UTC Offset"]
    CSV.generate(headers: headers, write_headers: true) do |csv|
      @repeaters
        .where(band: [Repeater::BAND_2M, Repeater::BAND_70CM]) # ID-52 can only do VHF and UHF.
        .where.not(operational: false) # Skip repeaters known to not be operational.
        .merge(Repeater.where(fm: true).or(Repeater.where(dstar: true))) # ID-52 does FM and DStar only
        .order(:name, :call_sign)
        .each do |repeater|
        if repeater.fm?
          csv << fm_repeater(repeater)
        end
        if repeater.dstar?
          csv << dstar_repeater(repeater)
        end
      end
    end
  end

  protected

  # Max lengths for each field is defined on page iv of the Icom ID-52 Advance Manual. We are assuming it's the same for
  # the ID-51, but if not, this might need changing.
  MAX_COUNTRY_NAME_LENGTH = 16
  MAX_NAME_LENGTH = 16
  MAX_SUB_NAME_LENGTH = 8
  MAX_CALL_SIGN_LENGTH = 8
  MAX_GATEWAY_CALL_SIGN_LENGTH = 8

  def repeater(repeater)
    group_name = truncate(MAX_COUNTRY_NAME_LENGTH, repeater.country.name) # TODO: do something smarter about groups: https://github.com/flexpointtech/repeater_world/issues/21
    name = truncate(MAX_NAME_LENGTH, repeater.name)
    sub_name = truncate(MAX_SUB_NAME_LENGTH, repeater.region_1)

    call_sign = truncate(MAX_CALL_SIGN_LENGTH, repeater.call_sign&.tr("-", " ")) # In the UK, some call signs have a hyphen, but ID-52 doesn't like that.

    {"Group No" => 1, # TODO: do something smarter about groups: https://github.com/flexpointtech/repeater_world/issues/21
     "Group Name" => group_name,
     "Name" => name,
     "Sub Name" => sub_name,
     "Repeater Call Sign" => call_sign,
     "Frequency" => frequency_in_mhz(repeater.tx_frequency, precision: 6),
     "Dup" => (repeater.tx_frequency > repeater.rx_frequency) ? "DUP-" : "DUP+",
     "Offset" => frequency_in_mhz((repeater.tx_frequency - repeater.rx_frequency).abs, precision: 6),
     "RPT1USE" => "YES", # Yes, we want to use the repeater.
     "Position" => "Approximate", # TODO: define when to use Approximate and when to use Exact: https://github.com/flexpointtech/repeater_world/issues/22
     "Latitude" => "%.6f" % repeater.latitude,
     "Longitude" => "%.6f" % repeater.longitude,
     "UTC Offset" => repeater.utc_offset || "--:--"}
  end

  def fm_repeater(repeater)
    row = repeater(repeater)

    row["Mode"] = "FM"

    if !repeater.access_method.present?
      row["Sub Name"] = "No CTCSS" # We are missing the CTCSS here.
    end

    row["TONE"] = case repeater.access_method
    when Repeater::CTCSS
      "TONE" # TODO: when do we use TSQL: https://github.com/flexpointtech/repeater_world/issues/23
    else
      "OFF" # Repeater::TONE_BURST or NULL is "OFF".
    end

    row["Repeater Tone"] = case repeater.access_method
    when Repeater::CTCSS
      "#{repeater.ctcss_tone}Hz"
    else
      "88.5Hz" # ID-52 insists on having some value here, even if it makes no sense and it's not used. The ID-51 has a similar broken behaviour.
    end

    row
  end

  # Max lengths for each field is defined on page iv of the Icom ID-52 Advance Manual
  def dstar_repeater(repeater)
    row = repeater(repeater)

    row["Mode"] = "DV"

    if repeater.call_sign.include? "-"
      call_sign_and_port = repeater.call_sign.split("-")
      row["Repeater Call Sign"] = truncate(MAX_CALL_SIGN_LENGTH,
        add_dstar_port(call_sign_and_port.first, call_sign_and_port.second))
    else
      row["Repeater Call Sign"] = truncate(MAX_CALL_SIGN_LENGTH,
        add_dstar_port(repeater.call_sign,
          conventional_dstar_port(repeater.band, repeater.country.id)))
    end

    row["Gateway Call Sign"] = truncate(MAX_GATEWAY_CALL_SIGN_LENGTH,
      add_dstar_port(repeater.call_sign.split("-").first, "G")) # Always "G" according to page 5-30 of the ID-52 Advanced manual

    row
  end
end
