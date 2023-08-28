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

class ChirpExporter < Exporter
  def export
    @repeaters = @repeaters.where(band: [Repeater::BAND_2M, Repeater::BAND_70CM])
      .where("operational IS NOT FALSE") # Skip repeaters known to not be operational.
      .where(fm: true)
      .order(:name, :call_sign)

    CSV.generate(headers: HEADERS, write_headers: true) do |csv|
      @repeaters.each_with_index do |repeater, index|
        csv << to_repeater_row(repeater).merge({LOCATION => index})
      end
    end
  end

  private

  HEADERS = [
    LOCATION = "Location",
    NAME = "Name",
    FREQUENCY = "Frequency",
    DUPLEX = "Duplex",
    OFFSET = "Offset",
    TONE = "Tone",
    R_TONE_FREQ = "rToneFreq",
    C_TONE_FREQ = "cToneFreq",
    DTCS_CODE = "DtcsCode",
    DTCS_POLARITY = "DtcsPolarity",
    RX_DTCS_CODE = "RxDtcsCode",
    CROSS_MODE = "CrossMode",
    MODE = "Mode",
    TSTEP = "TStep",
    SKIP = "Skip",
    POWER = "Power",
    COMMENT = "Comment",
    URCALL = "URCALL",
    RPT1CALL = "RPT1CALL",
    RPT2CALL = "RPT2CALL",
    DVCODE = "DVCODE"
  ]

  def to_repeater_row(repeater)
    row = {
      FREQUENCY => frequency_in_mhz(repeater.rx_frequency, precision: 6),
      DUPLEX => (repeater.tx_frequency > repeater.rx_frequency) ? "-" : "+",
      OFFSET => frequency_in_mhz((repeater.tx_frequency - repeater.rx_frequency).abs, precision: 6),
      DTCS_CODE => "023", # TODO: what's this? https://github.com/flexpointtech/repeater_world/issues/28
      DTCS_POLARITY => "NN", # TODO: what's this? https://github.com/flexpointtech/repeater_world/issues/28
      RX_DTCS_CODE => "023", # TODO: what's this? https://github.com/flexpointtech/repeater_world/issues/28
      CROSS_MODE => "Tone->Tone", # TODO: what's this? https://github.com/flexpointtech/repeater_world/issues/28
      MODE => "FM", # Always FM.
      TSTEP => "5.00", # Just the default, not sure if it has any effect.
      POWER => "50W", # TODO: this is the default, but could this value lower the power on a radio that receives CHIRP?
      COMMENT => "#{repeater.name} #{repeater.call_sign}"
    }

    row[NAME] =
      truncate(7, repeater.call_sign)

    if repeater.fm_ctcss_tone.present?
      row[TONE] = "Tone" # TODO: when do we use TSQL: https://github.com/flexpointtech/repeater_world/issues/23
    end

    row[R_TONE_FREQ] = repeater.fm_ctcss_tone || 88.5 # When blank it seems to go to 88.5, default?

    row[C_TONE_FREQ] = row[R_TONE_FREQ]

    row
  end
end
