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

RSpec.describe RepeaterGeocoder do
  it "should geocode" do
    skip # This test doesn't make sense anymore with the new approach.

    Geocoder::Lookup::Test.add_stub("New York, United States", [
      {"coordinates" => [40.7143528, -74.0059731],
       "address" => "New York, NY, USA",
       "state" => "New York",
       "state_code" => "NY",
       "country" => "United States",
       "country_code" => "US"}
    ])
    Geocoder::Lookup::Test.add_stub("Atlantis, Italy", [])

    Repeater.destroy_all

    # None of these should get geocoded.
    create(:repeater, name: "No address")
    create(:repeater, name: "Manual location", input_latitude: 40, input_longitude: -74, locality: "New York", country_id: "us")
    create(:repeater, name: "Recently geocoded", latitude: 40, longitude: -74,
      locality: "New York", country_id: "us", geocoded_at: 1.minute.ago, geocoded_by: "magic")

    expect(RepeaterGeocoder.new.geocode).to eq({geocoded_repeater_count: 0,
                                                 repeaters_to_geocode_count: 0,
                                                 repeater_count: 3})

    # These should get geocoded.
    create(:repeater, name: "Not geocoded", input_locality: "New York", input_country_id: "us")
    create(:repeater, name: "Stale geocoding",
      input_locality: "New York", input_country_id: "us",
      geocoded_at: 2.years.ago, geocoded_by: "magic",
      locality: "New York", country_id: "us", latitude: 40, longitude: -74)
    create(:repeater, name: "Locality Change",
      input_locality: "New York", input_country_id: "us",
      geocoded_at: 2.years.ago, geocoded_by: "magic",
      locality: "New York City", country_id: "us", latitude: 40, longitude: -74)
    create(:repeater, name: "Null Island", latitude: 0, longitude: 0.001,
      input_locality: "New York", input_country_id: "us",
      geocoded_at: 1.years.ago, geocoded_by: "magic",
      locality: "New York City", country_id: "us")
    create(:repeater, name: "Ungeocodable",
      input_locality: "Atlantis", input_country_id: "it")

    expect(RepeaterGeocoder.new.geocode).to eq({geocoded_repeater_count: 4,
                                                 repeaters_to_geocode_count: 5,
                                                 repeater_count: 8})

    # Now nothing should be geocoded again.
    expect(RepeaterGeocoder.new.geocode).to eq({geocoded_repeater_count: 0,
                                                 repeaters_to_geocode_count: 1,
                                                 repeater_count: 8})
  end
end
