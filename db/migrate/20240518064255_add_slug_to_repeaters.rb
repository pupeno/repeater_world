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

class AddSlugToRepeaters < ActiveRecord::Migration[7.1]
  def change
    add_column :repeaters, :slug, :string
    add_index :repeaters, :slug, unique: true
    unless reverting?
      say_with_time("Generating slugs for all repeaters") do
        Repeater.reset_column_information
        Repeater.find_each do |repeater|
          # First, the old slugs, to populate history.
          repeater.slug = [repeater.id,
            repeater.call_sign&.parameterize,
            repeater.name&.parameterize].reject(&:blank?).join("-")
          repeater.save!
          # And now autogenerate the new slug.
          repeater.slug = nil
          repeater.save!
        end
      end
    end
    change_column_null :repeaters, :slug, false
  end
end
