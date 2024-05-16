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

require "rails_helper"

RSpec.describe RepeaterUtils do
  it "should convert frequencies to MHz" do
    expect(RepeaterUtils.frequency_in_mhz(1_000_000)).to eq("1.0MHz")
  end

  it "should calculate frequency offsets in khz" do
    expect(RepeaterUtils.frequency_offset_in_khz(1_000_000, 1_025_000)).to eq("+25kHz")
    expect(RepeaterUtils.frequency_offset_in_khz(1_025_000, 1_000_000)).to eq("-25kHz")
  end

  it "should show distance in various units" do
    expect(RepeaterUtils.distance_in_unit(2500, "km")).to eq("2.5km")
    expect(RepeaterUtils.distance_in_unit(2500, "miles")).to eq("1.55 miles")
  end

  context "with a repeater" do
    before do
      @repeater = create(:repeater)
    end

    it "should extract mode names" do
      @repeater.fm = true
      @repeater.dstar = true

      expect(RepeaterUtils.mode_names(@repeater)).to eq(["FM", "D-Star"])
    end

    it "should extract mode symbols" do
      @repeater.fm = true
      @repeater.dstar = true

      expect(RepeaterUtils.modes_as_sym(@repeater)).to eq(Set.new([:fm, :dstar]))
    end

    it "should generate location in words" do
      @repeater.address = "address"
      @repeater.locality = "locality"
      @repeater.region = "region"
      @repeater.post_code = "post_code"
      expect(RepeaterUtils.location_in_words(@repeater)).to eq("address, locality, region, post_code, United Kingdom")
    end
  end
end
