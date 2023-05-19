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

class IcomId51Exporter < IcomExporter
  def dstar_repeater(repeater)
    row = super(repeater)

    row["TONE"] = "OFF" # It's D-Star, of course it's off. But ID-51 seems to want it this way.
    row["Repeater Tone"] = "88.5Hz" # ID-51 insists it wants this to be 88.5Hz. The ID-52 has a similar broken behaviour.
    row
  end
end
