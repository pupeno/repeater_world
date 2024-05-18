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

class CreatePgSearchDocumentsAgain < ActiveRecord::Migration[7.1]
  def up
    say_with_time("Creating table for pg_search multisearch") do
      create_table :pg_search_documents, id: :uuid do |t|
        t.text :content
        t.belongs_to :searchable, polymorphic: true, type: :uuid, index: true
        t.belongs_to :repeater, index: true, type: :uuid, null: true
        t.timestamps null: false
      end
    end
    say_with_time("Building index of all repeaters") do
      PgSearch::Multisearch.rebuild(Repeater)
    end
  end

  def down
    say_with_time("Dropping table for pg_search multisearch") do
      drop_table :pg_search_documents
    end
  end
end
