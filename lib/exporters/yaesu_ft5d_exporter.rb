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

class YaesuFt5dExporter < Exporter
  def export
    headers = [
      CHANNEL_NO, PRIORITY_CH, RX_FREQ, TX_FREQ, OFFSET_FREQ, OFFSET_DIR, AUTO_MODE, OPERATING_MODE, DIG_ANALOG, TAG,
      NAME, TONE_MODE, CTCSS_FREQ, DCS_CODE, DCS_POLARITY, USER_CTCSS, RX_DG_ID, TX_DG_ID, TX_POWER, SKIP, AUTO_STEP,
      STEP, MEMORY_MASK, ATT, S_METER_SQL, BELL, NARROW, CLOCK_SHIFT, BANK1, BANK2, BANK3, BANK4, BANK5, BANK6, BANK7,
      BANK8, BANK9, BANK10, BANK11, BANK12, BANK13, BANK14, BANK15, BANK16, BANK17, BANK18, BANK19, BANK20, BANK21,
      BANK22, BANK23, BANK24, COMMENT, LAST
    ]

    channel_number = 1
    CSV.generate(headers: headers, write_headers: false) do |csv|
      @repeaters
        .where(band: [Repeater::BAND_2M, Repeater::BAND_70CM]) # TODO: can the FT5D do other bands? https://github.com/flexpointtech/repeater_world/issues/24
        .where.not(operational: false) # Skip repeaters known to not be operational.
        .merge(Repeater.where(fm: true).or(Repeater.where(fusion: true))) # FT5D does FM and Fusion
        .order(:name, :call_sign)
        .each do |repeater|
        csv << repeater(repeater).merge({CHANNEL_NO => channel_number})
        channel_number += 1 # TODO: maybe do something better with channel numbers: https://github.com/flexpointtech/repeater_world/issues/25
      end

      # Are you serious Yaesu???? Without this, the file just doesn't import.
      while channel_number <= 900
        csv << {CHANNEL_NO => channel_number, LAST => 0}
        channel_number += 1
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
  NAME = "Name" # In the manual, this is call tag, in the radio it has no name, in the ADMS-14 UI this is called name, and there's another field called TAG which is a boolean (just before).
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
  LAST = "LAST" # There's a last field that's not on the UI, that's always 0, and without it, the file doesn't import.

  MAX_NAME_LENGTH = 16 # Specified on page 32 of the Operating Manual.

  OFF = "OFF"
  ON = "ON"

  def repeater(repeater)
    row = {
      PRIORITY_CH => OFF,
      RX_FREQ => frequency_in_mhz(repeater.tx_frequency, precision: 5), # Yaesu seems to call TX RX...
      TX_FREQ => frequency_in_mhz(repeater.rx_frequency, precision: 5), # ... and RX TX (or vice versa).
      OFFSET_FREQ => frequency_in_mhz((repeater.tx_frequency - repeater.rx_frequency).abs, precision: 5),
      OFFSET_DIR => (repeater.tx_frequency > repeater.rx_frequency) ? "-RPT" : "+RPT",
      AUTO_MODE => ON, # TODO: What's this? https://github.com/flexpointtech/repeater_world/issues/26
      OPERATING_MODE => "FM", # Digital modes work over FM, I think, so this is always FM.
      DCS_CODE => "023", # TODO: What's this? https://github.com/flexpointtech/repeater_world/issues/26
      DCS_POLARITY => "RX Normal TX Normal", # TODO: What's this? https://github.com/flexpointtech/repeater_world/issues/26
      USER_CTCSS => "1600 Hz", # TODO: What's this? https://github.com/flexpointtech/repeater_world/issues/26
      RX_DG_ID => "RX 00", # TODO: What's this? https://github.com/flexpointtech/repeater_world/issues/26
      TX_DG_ID => "TX 00", # TODO: What's this? https://github.com/flexpointtech/repeater_world/issues/26
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
      COMMENT => repeater.notes,
      LAST => 0
    }

    row[NAME] = if repeater.call_sign.present?
      "#{truncate(MAX_NAME_LENGTH - repeater.call_sign.length - 1, repeater.name)} #{repeater.call_sign}"
    else
      truncate(MAX_NAME_LENGTH, repeater.name).to_s
    end

    row[DIG_ANALOG] = if repeater.fm? && repeater.fusion?
      "AMS" # Auto mode, FM or DN
    elsif repeater.fm? && !repeater.fusion?
      "FM"
    elsif !repeater.fm? && repeater.fusion?
      "DN"
    else
      raise "Unknown fm/fusion conditions for repeater #{repeater}"
    end

    row[TONE_MODE] = case repeater.access_method
    when Repeater::CTCSS
      "TONE" # TODO: when do we use TSQL: https://github.com/flexpointtech/repeater_world/issues/23
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
end
