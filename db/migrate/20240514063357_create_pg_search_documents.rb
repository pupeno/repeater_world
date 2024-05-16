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

class CreatePgSearchDocuments < ActiveRecord::Migration[7.1]
  def up
    say_with_time("Creating table for pg_search multisearch") do
      create_table :pg_search_documents do |t|
        t.text :content
        t.belongs_to :searchable, polymorphic: true, index: true, type: :uuid
        t.string "name", null: true
        t.string "call_sign", null: true
        t.boolean "fm", null: true
        t.decimal "fm_ctcss_tone", null: true
        t.boolean "dstar", null: true
        t.boolean "fusion", null: true
        t.boolean "dmr", null: true
        t.boolean "nxdn", null: true
        t.boolean "p25", null: true
        t.boolean "tetra", null: true
        t.bigint "tx_frequency", null: true
        t.bigint "rx_frequency", null: true
        t.string "band", null: true
        t.boolean "operational", null: true
        t.string "address", null: true
        t.string "locality", null: true
        t.string "region", null: true
        t.string "post_code", null: true
        t.string "country_id", null: true
        t.string "country_name", null: true
        t.string "grid_square", null: true
        t.decimal "latitude", null: true
        t.decimal "longitude", null: true
        t.geography "location", limit: {srid: 4326, type: "st_point", geographic: true}
        t.timestamps null: false
      end
    end
  end

  def down
    say_with_time("Dropping table for pg_search multisearch") do
      drop_table :pg_search_documents
    end
  end
end
