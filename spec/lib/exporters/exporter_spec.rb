# Copyright 2023, Flexpoint Tech
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

require "rails_helper"

RSpec.describe Exporter do
  include_context "repeaters"

  it "should not export" do
    exporter = Exporter.new(Repeater.all)
    expect { exporter.export }.to raise_exception("Method should be implemented in subclass.")
  end

  it "should know conventional D-Star ports" do
    exporter = Exporter.new(Repeater.all)
    expect(exporter.send(:conventional_dstar_port, Repeater::BAND_23CM, "jp")).to eq("B")
    expect(exporter.send(:conventional_dstar_port, Repeater::BAND_70CM, "jp")).to eq("A")
    expect { exporter.send(:conventional_dstar_port, Repeater::BAND_2M, "jp") }.to raise_exception("Unexpected band #{Repeater::BAND_2M} in Japan")

    expect(exporter.send(:conventional_dstar_port, Repeater::BAND_23CM, "gb")).to eq("A")
    expect(exporter.send(:conventional_dstar_port, Repeater::BAND_70CM, "gb")).to eq("B")
    expect(exporter.send(:conventional_dstar_port, Repeater::BAND_2M, "gb")).to eq("C")
    expect { exporter.send(:conventional_dstar_port, Repeater::BAND_4M, "gb") }.to raise_exception("Unexpected band #{Repeater::BAND_4M}")
  end
end
