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

module RepeaterHelper
  def access_method_name(access_method)
    if access_method == Repeater::TONE_BURST
      "tone burst"
    elsif access_method == Repeater::CTCSS
      "CTCSS"
    elsif access_method.present? # If it's present, then it's an error.
      throw "Unexpected access method: \"#{access_method}\""
    end
  end
end
