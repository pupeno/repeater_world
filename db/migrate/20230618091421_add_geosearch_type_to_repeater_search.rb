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

class AddGeosearchTypeToRepeaterSearch < ActiveRecord::Migration[7.0]
  def change
    add_column :repeater_searches, :geosearch_type, :string

    RepeaterSearch.reset_column_information
    RepeaterSearch.where(geosearch: true).update_all(geosearch_type: "coordinates")
  end
end
