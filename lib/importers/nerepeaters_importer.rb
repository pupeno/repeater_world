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

class NerepeatersImporter < Importer
  SOURCE = "http://www.nerepeaters.com/"
  EXPORT_URL = "http://www.nerepeaters.com/NERepeaters.php"

  def import
    @logger.info "Importing repeaters from #{SOURCE}."
    file_name = download_file(EXPORT_URL, "nerepeaters.csv")

    ignored_due_to_source_count = 0
    create_or_updated_ids = []
    repeaters_deleted_count = 0

    @logger.info "Done importing from #{SOURCE}. #{create_or_updated_ids.count} created or updated, #{ignored_due_to_source_count} ignored due to source, #{repeaters_deleted_count} deleted."
  end
end
