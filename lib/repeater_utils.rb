# Copyright 2024, Pablo Fernandez
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

module RepeaterUtils
  def self.frequency_in_khz(frequency)
    "#{frequency.to_f / (10**3)}kHz" if frequency.present?
  end

  def self.frequency_in_mhz(frequency)
    "#{frequency.to_f / (10**6)}MHz"
  end

  def self.frequency_offset_in_khz(tx_frequency, rx_frequency)
    sign = (rx_frequency - tx_frequency > 0) ? "+" : "" # Artificially adding the +, because the int 600 renders as 600, not +600
    raw_offset = ((rx_frequency.to_f - tx_frequency) / (10**3)).to_i
    "#{sign}#{raw_offset}kHz"
  end

  def self.mode_names(repeater)
    Repeater::MODES.select { |mode| repeater.send(:"#{mode}") }.map { |mode| Repeater::MODE_NAMES[mode] }
  end

  def self.modes_as_sym(repeater)
    Set.new Repeater::MODES.select { |mode| repeater.send(:"#{mode}?") }.map(&:to_sym)
  end

  def self.distance_in_unit(distance, unit)
    distance = (distance / ((unit == "miles") ? 1609.34 : 1000.0)).round(2)
    if unit == "miles"
      "#{distance} miles"
    else
      "#{distance}km"
    end
  end

  def self.location_in_words(repeater)
    [repeater.address, repeater.locality, repeater.region, repeater.post_code, repeater.try(:country_name) || repeater.country.name].reject(&:blank?).join(", ")
  end
end
