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

class SeparateToneBurstAndCtcss < ActiveRecord::Migration[7.0]
  def change
    rename_column :repeaters, :ctcss_tone, :fm_ctcss_tone
    rename_column :repeaters, :tone_sql, :fm_tone_squelch
    add_column :repeaters, :fm_tone_burst, :boolean, null: true
    Repeater.reset_column_information
    Repeater.find_each do |repeater|
      if repeater.access_method == "tone_burst"
        repeater.update_column(:fm_tone_burst, true)
      elsif repeater.access_method == "ctcss"
        repeater.update_column(:fm_tone_burst, false)
      end
    end
    remove_column :repeaters, :access_method

    rename_column :suggested_repeaters, :ctcss_tone, :fm_ctcss_tone
    add_column :suggested_repeaters, :fm_tone_burst, :boolean, null: true
    rename_column :suggested_repeaters, :tone_sql, :fm_tone_squelch
    SuggestedRepeater.reset_column_information
    SuggestedRepeater.find_each do |repeater|
      if repeater.access_method == "tone_burst"
        repeater.update_column(:fm_tone_burst, true)
      elsif repeater.access_method == "ctcss"
        repeater.update_column(:fm_tone_burst, false)
      end
    end
    remove_column :suggested_repeaters, :access_method
  end
end
