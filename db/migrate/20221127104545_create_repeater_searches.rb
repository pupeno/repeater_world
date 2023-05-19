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

class CreateRepeaterSearches < ActiveRecord::Migration[7.0]
  def change
    create_table :repeater_searches, id: :uuid do |t|
      t.references :user, foreign_key: true, type: :uuid

      t.boolean :band_10m
      t.boolean :band_6m
      t.boolean :band_4m
      t.boolean :band_2m
      t.boolean :band_70cm
      t.boolean :band_23cm

      t.boolean :fm
      t.boolean :dstar
      t.boolean :fusion
      t.boolean :dmr
      t.boolean :nxdn

      t.boolean :distance_to_coordinates
      t.integer :distance
      t.string :distance_unit
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
  end
end
