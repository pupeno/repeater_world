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

class RefactorLocationFieldsInRepeaterAndSuggestedRepeaters < ActiveRecord::Migration[7.0]
  def change
    remove_column :repeaters, :region_1
    remove_column :repeaters, :region_2
    remove_column :repeaters, :region_3
    remove_column :repeaters, :region_4
    remove_column :repeaters, :country_id

    add_column :repeaters, :address, :string
    add_column :repeaters, :locality, :string
    add_column :repeaters, :region, :string
    add_column :repeaters, :post_code, :string
    add_reference :repeaters, :country, foreign_key: true, type: :string

    remove_column :suggested_repeaters, :region_1
    remove_column :suggested_repeaters, :region_2
    remove_column :suggested_repeaters, :region_3
    remove_column :suggested_repeaters, :region_4
    remove_column :suggested_repeaters, :country

    add_column :suggested_repeaters, :address, :string
    add_column :suggested_repeaters, :locality, :string
    add_column :suggested_repeaters, :region, :string
    add_column :suggested_repeaters, :post_code, :string
    add_column :suggested_repeaters, :country, :string
  end
end
