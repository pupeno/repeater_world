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

class SeparateInputFromComputedLocation < ActiveRecord::Migration[7.1]
  def change
    # Cleanly separate input data, which will be processed into the right fields in the data for the repeater. This is
    # to avoid calculating the coordinates from the grid and the grid from the coordinates at the same time. Sometimes
    # the authoritative information is the coordinates, sometimes it's the grid.
    rename_column :repeaters, :address, :input_address
    rename_column :repeaters, :locality, :input_locality
    rename_column :repeaters, :region, :input_region
    rename_column :repeaters, :post_code, :input_post_code
    rename_column :repeaters, :grid_square, :input_grid_square
    # Here we should be renaming country_id to input_country_id, but if we do that the current code breaks. So we are
    # creating a new field and later on deleting geocoded_country_id when no longer used. Technically we are mixing data
    # here, but all *_country_ids have the same values so it's not a problem.
    add_reference :repeaters, :input_country, foreign_key: {to_table: :countries}, type: :string
    add_column :repeaters, :input_location, :st_point, geographic: true
    add_index :repeaters, :input_location

    rename_column :repeaters, :geocoded_address, :address
    rename_column :repeaters, :geocoded_locality, :locality
    rename_column :repeaters, :geocoded_region, :region
    rename_column :repeaters, :geocoded_post_code, :post_code
    # Here geocoded_country_id should be renamed to country_id, but since we are not renaming country_id, we are just
    # reusing it. A bit messy, but temporarily and with our current levels of updates, it's fine.
    add_column :repeaters, :grid_square, :string

    say_with_time("Populating new field input_count_id") do
      Repeater.reset_column_information
      Repeater.update_all("input_country_id = country_id") # Make sure the new country_id field is properly populated.
    end
  end
end
