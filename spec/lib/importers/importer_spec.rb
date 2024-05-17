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

require "rails_helper"

RSpec.describe Importer do
  it "should delegate an interface to subclasses" do
    expect { Importer.source }.to raise_error(/Importer subclasses must implement this method/)
    importer = Importer.new
    expect { importer.import }.to raise_error(/Importer subclasses must implement this method/)
    importer = Importer.new
    expect { importer.send(:import_data) }.to raise_error(/Importer subclasses must implement this method/)
  end
end
