# Copyright 2023-2024, Pablo Fernandez
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
  def frequency_in_mhz(...)
    RepeaterUtils.frequency_in_mhz(...)
  end

  def frequency_offset_in_khz(...)
    RepeaterUtils.frequency_offset_in_khz(...)
  end

  def modes(...)
    RepeaterUtils.mode_names(...)
  end

  def modes_as_sym(...)
    RepeaterUtils.modes_as_sym(...)
  end

  def distance_in_unit(...)
    RepeaterUtils.distance_in_unit(...)
  end

  def location_in_words(...)
    RepeaterUtils.location_in_words(...)
  end
end
