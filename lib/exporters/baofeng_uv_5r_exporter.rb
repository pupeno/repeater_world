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

class BaofengUv5rExporter < Exporter
  def export
    headers = [
      LOCATION, NAME, FREQUENCY, DUPLEX, OFFSET, TONE, R_TONE_FREQ, C_TONE_FREQ, DTCS_CODE, DTCS_POLARITY, MODE, TSTEP,
      SKIP, COMMENT, URCALL, RPT1CALL, RPT2CALL, DVCODE
    ]

    @repeaters = @repeaters.where(band: [Repeater::BAND_2M, Repeater::BAND_70CM])
      .where("operational IS NOT FALSE") # Skip repeaters known to not be operational.
      .where(fm: true)
      .order(:name, :call_sign)

    CSV.generate(headers: headers, write_headers: true) do |csv|
      @repeaters.each_with_index do |repeater, index|
        csv << to_repeater_row(repeater).merge({LOCATION => index})
        if index >= 127 # Baofeng UV-5R can only have 127 memories.
          break
        end
      end
    end
  end

  private

  LOCATION = "Location"
  NAME = "Name"
  FREQUENCY = "Frequency"
  DUPLEX = "Duplex"
  OFFSET = "Offset"
  TONE = "Tone"
  R_TONE_FREQ = "rToneFreq"
  C_TONE_FREQ = "cToneFreq"
  DTCS_CODE = "DtcsCode"
  DTCS_POLARITY = "DtcsPolarity"
  MODE = "Mode"
  TSTEP = "TStep"
  SKIP = "Skip"
  COMMENT = "Comment"
  URCALL = "URCALL"
  RPT1CALL = "RPT1CALL"
  RPT2CALL = "RPT2CALL"
  DVCODE = "DVCODE"

  def to_repeater_row(repeater)
    row = {
      FREQUENCY => frequency_in_mhz(repeater.rx_frequency, precision: 6),
      DUPLEX => (repeater.tx_frequency > repeater.rx_frequency) ? "-" : "+",
      OFFSET => frequency_in_mhz((repeater.tx_frequency - repeater.rx_frequency).abs, precision: 6),
      DTCS_CODE => "023", # TODO: what's this? https://github.com/flexpointtech/repeater_world/issues/28
      DTCS_POLARITY => "NN", # TODO: what's this? https://github.com/flexpointtech/repeater_world/issues/28
      MODE => "FM", # Always FM.
      TSTEP => 5, # Default?
      COMMENT => "#{repeater.name} #{repeater.call_sign}"
    }

    row[NAME] =
      truncate(7, repeater.call_sign)

    row[TONE] = if repeater.fm_ctcss_tone.present?
      "TONE" # TODO: when do we use TSQL: https://github.com/flexpointtech/repeater_world/issues/23
    end

    row[R_TONE_FREQ] = repeater.fm_ctcss_tone || 88.5 # Default?

    row[C_TONE_FREQ] = row[R_TONE_FREQ]

    row
  end
end
