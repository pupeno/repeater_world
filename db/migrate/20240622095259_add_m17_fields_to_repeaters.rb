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

class AddM17FieldsToRepeaters < ActiveRecord::Migration[7.1]
  def change
    add_column :repeaters, :m17, :boolean
    add_column :repeaters, :m17_can, :integer
    add_column :repeaters, :m17_reflector_name, :string
    add_column :suggested_repeaters, :m17, :boolean
    add_column :suggested_repeaters, :m17_can, :integer
    add_column :suggested_repeaters, :m17_reflector_name, :string
    add_column :repeater_searches, :m17, :boolean
    add_column :repeater_searches, :m17_can, :integer
    add_column :repeater_searches, :m17_reflector_name, :string
  end
end
