# Copyright 2023, Flexpoint Tech
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Foobar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
# <https://www.gnu.org/licenses/>.

class Exporter
  def initialize(repeaters)
    @repeaters = repeaters
  end

  def export
    raise NotImplementedError.new("Method should be implemented in subclass.")
  end

  protected

  # Returns the conventional DStar port.
  def conventional_dstar_port(band, country_code)
    if country_code == "jp"
      if band == Repeater::BAND_23CM
        "B"
      elsif band == Repeater::BAND_70CM
        "A"
      else
        raise "Unexpected band #{band} in Japan"
      end
    elsif band == Repeater::BAND_23CM
      "A"
    elsif band == Repeater::BAND_70CM
      "B"
    elsif band == Repeater::BAND_2M
      "C"
    else
      raise "Unexpected band #{band}"
    end
  end

  # Adds the port according to D-Star to a call sign. The port should always be the 8th character and the call sign
  # should be blank space padded accordingly. See page 5-32 of the Icom ID-52 Advanced Manual.
  def add_dstar_port(call_sign, port)
    "#{call_sign.ljust(6)} #{port}"
  end

  def frequency_in_mhz(freq, precision: 6)
    "%.#{precision}f" % (freq / 10**6)
  end

  def truncate(length, value)
    value&.truncate(length, omission: "")&.strip
  end
end
