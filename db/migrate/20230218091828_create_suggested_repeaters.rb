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

class CreateSuggestedRepeaters < ActiveRecord::Migration[7.0]
  def change
    create_table :suggested_repeaters, id: :uuid do |t|
      t.string :submitter_name
      t.string :submitter_email
      t.string :submitter_call_sign
      t.boolean :submitter_keeper
      t.text :submitter_notes

      t.string :name
      t.string :call_sign
      t.string :band
      t.string :channel
      t.string :keeper
      t.text :notes
      t.string :web_site

      t.string :tx_frequency
      t.string :rx_frequency

      t.boolean :fm
      t.string :access_method
      t.string :ctcss_tone
      t.boolean :tone_sql

      t.boolean :dstar

      t.boolean :fusion

      t.boolean :dmr
      t.string :dmr_color_code
      t.string :dmr_network

      t.boolean :nxdn

      t.string :latitude
      t.string :longitude
      t.string :grid_square
      t.string :country
      t.string :region_1
      t.string :region_2
      t.string :region_3
      t.string :region_4

      t.text :private_notes

      t.timestamps
    end
  end
end
