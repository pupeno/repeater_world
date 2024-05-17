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

class NewFieldsForRepeatersForSral < ActiveRecord::Migration[7.0]
  def change
    add_column :repeaters, :external_id, :string
    add_column :repeaters, :p25, :boolean
    add_column :repeaters, :tetra, :boolean
    add_column :repeaters, :tx_power, :numeric
    add_column :repeaters, :tx_antenna, :string
    add_column :repeaters, :tx_antenna_polarization, :string
    add_column :repeaters, :rx_antenna, :string
    add_column :repeaters, :rx_antenna_polarization, :string
    add_column :repeaters, :altitude_asl, :numeric
    add_column :repeaters, :altitude_agl, :numeric
    add_column :repeaters, :bearing, :string
  end
end
