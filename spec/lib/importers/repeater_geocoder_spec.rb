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

require "rails_helper"

RSpec.describe RepeaterGeocoder do
  it "should geocode" do
    Geocoder::Lookup::Test.add_stub("New York, United States", [
      {"coordinates" => [40.7143528, -74.0059731],
       "address" => "New York, NY, USA",
       "state" => "New York",
       "state_code" => "NY",
       "country" => "United States",
       "country_code" => "US"}
    ])
    Geocoder::Lookup::Test.add_stub("Atlantis, Italy", [])

    Repeater.delete_all

    # None of these should get geocoded.
    create(:repeater, name: "No address")
    create(:repeater, name: "Manual location", latitude: 40, longitude: -74, locality: "New York", country_id: "us")
    create(:repeater, name: "Recently geocoded", latitude: 40, longitude: -74,
      locality: "New York", country_id: "us", geocoded_at: 1.minute.ago, geocoded_by: "magic",
      geocoded_locality: "New York", geocoded_country_id: "us")

    expect(RepeaterGeocoder.new.geocode).to eq({geocoded_repeater_count: 0,
                                                repeaters_to_geocode_count: 0,
                                                repeater_count: 3})

    # These should get geocoded.
    create(:repeater, name: "No location", locality: "New York", country_id: "us")
    create(:repeater, name: "Stale geocoding", latitude: 40, longitude: -74,
      locality: "New York", country_id: "us", geocoded_at: 2.years.ago, geocoded_by: "magic",
      geocoded_locality: "New York", geocoded_country_id: "us")
    create(:repeater, name: "Locality Change", latitude: 40, longitude: -74,
      locality: "New York", country_id: "us", geocoded_at: 2.years.ago, geocoded_by: "magic",
      geocoded_locality: "New York City", geocoded_country_id: "us")
    create(:repeater, name: "Null Island", latitude: 0, longitude: 0.001,
      locality: "New York", country_id: "us", geocoded_at: 1.years.ago, geocoded_by: "magic",
      geocoded_locality: "New York City", geocoded_country_id: "us")
    create(:repeater, name: "Ungeocodable", locality: "Atlantis", country_id: "it")

    expect(RepeaterGeocoder.new.geocode).to eq({geocoded_repeater_count: 4,
                                                repeaters_to_geocode_count: 5,
                                                repeater_count: 8})

    # Now nothing should be geocoded again.
    expect(RepeaterGeocoder.new.geocode).to eq({geocoded_repeater_count: 0,
                                                repeaters_to_geocode_count: 1,
                                                repeater_count: 8})
  end
end
