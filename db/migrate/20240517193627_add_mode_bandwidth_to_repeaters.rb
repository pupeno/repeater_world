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

class AddModeBandwidthToRepeaters < ActiveRecord::Migration[7.1]
  def up
    add_column :repeaters, :bandwidth, :integer
    add_column :suggested_repeaters, :bandwidth, :string
    Repeater.reset_column_information
    Repeater.where(fm_bandwidth: Repeater::FM_WIDE).update_all(bandwidth: 25_000)
    Repeater.where(fm_bandwidth: Repeater::FM_NARROW).update_all(bandwidth: 12_500)
    remove_column :repeaters, :fm_bandwidth
  end
end
