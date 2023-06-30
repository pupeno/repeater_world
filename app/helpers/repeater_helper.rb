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

module RepeaterHelper
  def frequency_in_mhz(frequency)
    "#{frequency.to_f / (10 ** 6)}MHz"
  end

  def frequency_offset_in_khz(tx_frequency, rx_frequency)
    sign = (rx_frequency - tx_frequency > 0) ? "+" : "" # Artificially adding the +, because the int 600 renders as 600, not +600
    raw_offset = ((rx_frequency.to_f - tx_frequency) / (10 ** 3)).to_i
    "#{sign}#{raw_offset}kHz"
  end

  def modes(repeater)
    modes = []
    modes << "FM" if repeater.fm?
    modes << "D-Star" if repeater.dstar?
    modes << "Fusion" if repeater.fusion?
    modes << "DMR" if repeater.dmr?
    modes << "NXDN" if repeater.nxdn?
    modes << "P25" if repeater.p25?
    modes << "TETRA" if repeater.tetra?
    modes
  end

  def distance_in_unit(distance, unit)
    distance = (distance / ((unit == "miles") ? 1609.34 : 1000)).round(2)
    if unit == "miles"
      "#{distance} miles"
    else
      "#{distance}km"
    end
  end
end
