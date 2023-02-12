# Copyright 2023, Pablo Fernandez
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Foobar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with Foobar. If not, see
# <https://www.gnu.org/licenses/>.

class CreateRepeaters < ActiveRecord::Migration[7.0]
  def change
    create_table :repeaters, id: :uuid do |t|
      t.string :name
      t.string :call_sign, index: true
      t.string :band
      t.string :channel
      t.string :keeper
      t.boolean :operational
      t.text :notes

      t.decimal :tx_frequency
      t.decimal :rx_frequency

      t.boolean :fm
      t.string :access_method
      t.decimal :ctcss_tone
      t.boolean :tone_sql

      t.boolean :dstar

      t.boolean :fusion

      t.boolean :dmr
      t.integer :dmr_cc
      t.string :dmr_con

      t.boolean :nxdn

      t.st_point :location, geographic: true, index: {using: :gist}
      t.string :grid_square
      t.references :country, foreign_key: true, type: :string
      t.string :region_1
      t.string :region_2
      t.string :region_3
      t.string :region_4
      t.string :utc_offset

      t.string :source

      t.timestamps
    end
  end
end
