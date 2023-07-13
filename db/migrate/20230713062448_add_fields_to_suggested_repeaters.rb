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

class AddFieldsToSuggestedRepeaters < ActiveRecord::Migration[7.0]
  def change
    add_column :suggested_repeaters, :p25, :boolean
    add_column :suggested_repeaters, :tetra, :boolean
    add_column :suggested_repeaters, :tx_power, :string
    add_column :suggested_repeaters, :tx_antenna, :string
    add_column :suggested_repeaters, :tx_antenna_polarization, :string
    add_column :suggested_repeaters, :rx_antenna, :string
    add_column :suggested_repeaters, :rx_antenna_polarization, :string
    add_column :suggested_repeaters, :altitude_asl, :string
    add_column :suggested_repeaters, :altitude_agl, :string
    add_column :suggested_repeaters, :bearing, :string
    add_column :suggested_repeaters, :dstar_port, :string
  end
end
