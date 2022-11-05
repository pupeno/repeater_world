class YaesuFt5dExporter < Exporter
  def export
    headers = [
      CHANNEL_NO, PRIORITY_CH, RX_FREQ, TX_FREQ, OFFSET_FREQ, OFFSET_DIR, AUTO_MODE, OPERATING_MODE, DIG_ANALOG, TAG,
      NAME, TONE_MODE, CTCSS_FREQ, DCS_CODE, DCS_POLARITY, USER_CTCSS, RX_DG_ID, TX_DG_ID, TX_POWER, SKIP, AUTO_STEP,
      STEP, MEMORY_MASK, ATT, S_METER_SQL, BELL, NARROW, CLOCK_SHIFT, BANK1, BANK2, BANK3, BANK4, BANK5, BANK6, BANK7,
      BANK8, BANK9, BANK10, BANK11, BANK12, BANK13, BANK14, BANK15, BANK16, BANK17, BANK18, BANK19, BANK20, BANK21,
      BANK22, BANK23, BANK24, COMMENT
    ]

    CSV.generate(headers: headers, write_headers: false) do |csv|
      @repeaters
        .where(band: [Repeater::BAND_2M, Repeater::BAND_70CM]) # TODO: can the FT5D do other bands?
        .where.not(operational: false) # Skip repeaters known to not be operational.
        .where(fm: true).or(Repeater.where(fusion: true)) # FT5D does FM and Fusion
        .order(:name, :call_sign)
        .each do |repeater|
        if repeater.fm?
          csv << fm_repeater(repeater)
        end
        if repeater.fusion?
          csv << fusion_repeater(repeater)
        end
      end
    end
  end

  private

  CHANNEL_NO = "Channel No"
  PRIORITY_CH = "Priority CH"
  RX_FREQ = "Receive Frequency"
  TX_FREQ = "Transmit Frequency"
  OFFSET_FREQ = "Offset Frequency"
  OFFSET_DIR = "Offset Direction"
  AUTO_MODE = "AUTO MODE"
  OPERATING_MODE = "Operating Mode"
  DIG_ANALOG = "DIG/ANALOG"
  TAG = "TAG"
  NAME = "Name"
  TONE_MODE = "Tone Mode"
  CTCSS_FREQ = "CTCSS Frequency"
  DCS_CODE = "DCS Code"
  DCS_POLARITY = "DCS Polarity"
  USER_CTCSS = "User CTCSS"
  RX_DG_ID = "RX DG-ID"
  TX_DG_ID = "TX DG-ID"
  TX_POWER = "Tx Power"
  SKIP = "Skip"
  AUTO_STEP = "AUTO STEP"
  STEP = "Step"
  MEMORY_MASK = "Memory Mask"
  ATT = "ATT"
  S_METER_SQL = "S-Meter SQL"
  BELL = "Bell"
  NARROW = "Narrow"
  CLOCK_SHIFT = "Clock Shift"
  BANK1 = "BANK1"
  BANK2 = "BANK2"
  BANK3 = "BANK3"
  BANK4 = "BANK4"
  BANK5 = "BANK5"
  BANK6 = "BANK6"
  BANK7 = "BANK7"
  BANK8 = "BANK8"
  BANK9 = "BANK9"
  BANK10 = "BANK10"
  BANK11 = "BANK11"
  BANK12 = "BANK12"
  BANK13 = "BANK13"
  BANK14 = "BANK14"
  BANK15 = "BANK15"
  BANK16 = "BANK16"
  BANK17 = "BANK17"
  BANK18 = "BANK18"
  BANK19 = "BANK19"
  BANK20 = "BANK20"
  BANK21 = "BANK21"
  BANK22 = "BANK22"
  BANK23 = "BANK23"
  BANK24 = "BANK24"
  COMMENT = "Comment"

  MAX_NAME_LENGTH = 16
  OFF = "OFF"
  ON = "ON"

  def repeater(repeater)
    {
      PRIORITY_CH => OFF,
      RX_FREQ => frequency_in_mhz(repeater.rx_frequency, precision: 5),
      TX_FREQ => frequency_in_mhz(repeater.tx_frequency, precision: 5),
      OFFSET_FREQ => frequency_in_mhz((repeater.tx_frequency - repeater.rx_frequency).abs, precision: 5),
      OFFSET_DIR => repeater.tx_frequency > repeater.rx_frequency ? "-RPT" : "+RPT",
      AUTO_MODE => ON, # TODO: What's this?
      TAG => ON, # TODO: What's this?"
      NAME => truncate(MAX_NAME_LENGTH, repeater.name),
      TONE_MODE => OFF, # Default.
      CTCSS_FREQ => "88.5 Hz", # Default
      DCS_CODE => "023", # TODO: What's this?
      USER_CTCSS => "1600 Hz", # TODO: What's this?
      RX_DG_ID => "RX 00", # TODO: What's this?
      TX_DG_ID => "TX 00", # TODO: What's this?
      TX_POWER => "High (5W)",
      SKIP => OFF,
      AUTO_STEP => ON,
      STEP => "12.5KHz",
      MEMORY_MASK => OFF,
      ATT => OFF,
      S_METER_SQL => OFF,
      BELL => OFF,
      NARROW => OFF,
      CLOCK_SHIFT => OFF,
      BANK1 => OFF,
      BANK2 => OFF,
      BANK3 => OFF,
      BANK4 => OFF,
      BANK5 => OFF,
      BANK6 => OFF,
      BANK7 => OFF,
      BANK8 => OFF,
      BANK9 => OFF,
      BANK10 => OFF,
      BANK11 => OFF,
      BANK12 => OFF,
      BANK13 => OFF,
      BANK14 => OFF,
      BANK15 => OFF,
      BANK16 => OFF,
      BANK17 => OFF,
      BANK18 => OFF,
      BANK19 => OFF,
      BANK20 => OFF,
      BANK21 => OFF,
      BANK22 => OFF,
      BANK23 => OFF,
      BANK24 => OFF,
      COMMENT => repeater.notes
    }
  end

  def fm_repeater(repeater)
    row = repeater(repeater)

    row[OPERATING_MODE] = "FM"
    row[DIG_ANALOG] = "FM"

    row[TONE_MODE] = case repeater.access_method
                       when Repeater::CTCSS
                         "TONE" # TODO: when do we use TSQL
                       else
                         OFF # Repeater::TONE_BURST or NULL is "OFF".
                     end

    row[CTCSS_FREQ] = case repeater.access_method
                        when Repeater::CTCSS
                          "#{repeater.ctcss_tone} Hz"
                        else
                          "88.5 Hz" # FT5D insists on having some value here, even if it makes no sense and it's not used. The ID-51 has a similar broken behaviour.
                      end

    row
  end

  def fusion_repeater(repeater)
    row = repeater(repeater)

    row
  end
end
