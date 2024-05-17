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

class AddNewBandsToRepeaterSearch < ActiveRecord::Migration[7.0]
  def change
    add_column :repeater_searches, :band_1_25m, :boolean, default: false, null: false
    add_column :repeater_searches, :band_33cm, :boolean, default: false, null: false
    add_column :repeater_searches, :band_13cm, :boolean, default: false, null: false
    add_column :repeater_searches, :band_9cm, :boolean, default: false, null: false
    add_column :repeater_searches, :band_6cm, :boolean, default: false, null: false
    add_column :repeater_searches, :band_3cm, :boolean, default: false, null: false

    change_column :repeater_searches, :band_10m, :boolean, default: false, null: false
    change_column :repeater_searches, :band_23cm, :boolean, default: false, null: false
    change_column :repeater_searches, :band_2m, :boolean, default: false, null: false
    change_column :repeater_searches, :band_4m, :boolean, default: false, null: false
    change_column :repeater_searches, :band_6m, :boolean, default: false, null: false
    change_column :repeater_searches, :band_70cm, :boolean, default: false, null: false
  end
end
