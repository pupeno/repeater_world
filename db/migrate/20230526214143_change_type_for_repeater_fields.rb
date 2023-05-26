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

class ChangeTypeForRepeaterFields < ActiveRecord::Migration[7.0]
  def change
    # These don't require decimal precision, and it's annoying in Rails.
    change_column(:repeaters, :tx_frequency, :integer, null: false)
    change_column(:repeaters, :rx_frequency, :integer, null: false)
    change_column(:repeaters, :tx_power, :integer)
    change_column(:repeaters, :altitude_asl, :integer)
    change_column(:repeaters, :altitude_agl, :integer)
  end
end
