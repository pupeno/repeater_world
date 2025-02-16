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

RSpec.describe RepeaterSearch, type: :model do
  context "When not geosearching" do
    before do
      @repeater_search = create(:repeater_search)
      expect(@repeater_search).to be_valid
    end

    it "validates distance" do
      # Distance can be missing but not invalid
      @repeater_search.distance = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance = nil
      expect(@repeater_search).to be_valid
      @repeater_search.distance = 10
      expect(@repeater_search).to be_valid
    end

    it "validates distance unit" do
      # Distance unit can be missing but not invalid
      @repeater_search.distance_unit = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance_unit = nil
      expect(@repeater_search).to be_valid
      @repeater_search.distance_unit = RepeaterSearch::KM
      expect(@repeater_search).to be_valid
    end

    it "doesn't validate place" do
      # Place can be missing.
      @repeater_search.place = nil
      expect(@repeater_search).to be_valid
      @repeater_search.place = ""
      expect(@repeater_search).to be_valid
      @repeater_search.place = "New York, NY, US"
      expect(@repeater_search).to be_valid
    end

    it "validates latitude" do
      # Latitude can be missing but not invalid.
      @repeater_search.latitude = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.latitude = nil
      expect(@repeater_search).to be_valid
      @repeater_search.latitude = 10.01
      expect(@repeater_search).to be_valid
    end

    it "validates longitude" do
      # Longitude can be missing but not invalid.
      @repeater_search.longitude = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.longitude = nil
      expect(@repeater_search).to be_valid
      @repeater_search.longitude = 20.02
      expect(@repeater_search).to be_valid
    end

    it "validates grid square" do
      # Grid square can be missing but not invalid.
      @repeater_search.grid_square = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.grid_square = nil
      expect(@repeater_search).to be_valid
      @repeater_search.grid_square = "FN22"
      expect(@repeater_search).to be_valid
      @repeater_search.grid_square = "FN22ab"
      expect(@repeater_search).to be_valid
    end
  end

  context "When geosearching by my location" do
    before do
      @repeater_search = create(:repeater_search,
        geosearch_type: RepeaterSearch::MY_LOCATION,
        distance: 10, distance_unit: RepeaterSearch::KM,
        latitude: 10.01, longitude: 20.02)
      expect(@repeater_search).to be_valid
    end

    it "validates distance" do
      # Distance can neither be missing nor be invalid.
      @repeater_search.distance = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance = nil
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance = 10
      expect(@repeater_search).to be_valid
    end

    it "validates distance unit" do
      # Distance unit can neither be missing nor be invalid.
      @repeater_search.distance_unit = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance_unit = nil
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance_unit = RepeaterSearch::KM
      expect(@repeater_search).to be_valid
    end

    it "doesn't validate place" do
      # Place can be missing.
      @repeater_search.place = nil
      expect(@repeater_search).to be_valid
      @repeater_search.place = ""
      expect(@repeater_search).to be_valid
      @repeater_search.place = "New York, NY, US"
      expect(@repeater_search).to be_valid
    end

    it "validates latitude" do
      # Latitude can neither be missing nor be invalid.
      @repeater_search.latitude = "invalid"
      expect(@repeater_search).to_not be_valid
      expect(@repeater_search.errors[:base]).to include("We couldn't get valid coordinates for your location")
      @repeater_search.latitude = nil
      expect(@repeater_search).to_not be_valid
      expect(@repeater_search.errors[:base]).to include("We couldn't get valid coordinates for your location")
      @repeater_search.latitude = 10.01
      expect(@repeater_search).to be_valid
    end

    it "validates longitude" do
      # Longitude can neither be missing nor be invalid.
      @repeater_search.longitude = "invalid"
      expect(@repeater_search).to_not be_valid
      expect(@repeater_search.errors[:base]).to include("We couldn't get valid coordinates for your location")
      @repeater_search.longitude = nil
      expect(@repeater_search).to_not be_valid
      expect(@repeater_search.errors[:base]).to include("We couldn't get valid coordinates for your location")
      @repeater_search.longitude = 20.02
      expect(@repeater_search).to be_valid
    end

    it "validates grid square" do
      # Grid square can be missing but not invalid.
      @repeater_search.grid_square = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.grid_square = nil
      expect(@repeater_search).to be_valid
      @repeater_search.grid_square = "FN22"
      expect(@repeater_search).to be_valid
      @repeater_search.grid_square = "FN22ab"
      expect(@repeater_search).to be_valid
    end
  end

  context "When geosearching by place" do
    before do
      Geocoder::Lookup::Test.add_stub("New York, NY, US",
        [{"coordinates" => [40.7143528, -74.0059731],
          "address" => "New York, NY, USA",
          "state" => "New York",
          "state_code" => "NY",
          "country" => "United States",
          "country_code" => "US"}])
      @repeater_search = create(:repeater_search,
        geosearch_type: RepeaterSearch::PLACE,
        distance: 10, distance_unit: RepeaterSearch::KM,
        place: "New York, NY, US")
      expect(@repeater_search).to be_valid
    end

    it "validates distance" do
      # Distance can neither be missing nor be invalid.
      @repeater_search.distance = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance = nil
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance = 10
      expect(@repeater_search).to be_valid
    end

    it "validates distance unit" do
      # Distance unit can neither be missing nor be invalid.
      @repeater_search.distance_unit = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance_unit = nil
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance_unit = RepeaterSearch::KM
      expect(@repeater_search).to be_valid
    end

    it "validates place" do
      # Place can be missing.
      @repeater_search.place = nil
      expect(@repeater_search).to_not be_valid
      @repeater_search.place = ""
      expect(@repeater_search).to_not be_valid
      @repeater_search.place = "New York, NY, US"
      expect(@repeater_search).to be_valid
    end

    it "validates latitude" do
      # Latitude can be missing but not invalid.
      @repeater_search.latitude = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.latitude = nil
      expect(@repeater_search).to be_valid
      @repeater_search.latitude = 10.01
      expect(@repeater_search).to be_valid
    end

    it "validates longitude" do
      # Longitude can be missing but not invalid.
      @repeater_search.longitude = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.longitude = nil
      expect(@repeater_search).to be_valid
      @repeater_search.longitude = 20.02
      expect(@repeater_search).to be_valid
    end

    it "validates grid square" do
      # Grid square can be missing but not invalid.
      @repeater_search.grid_square = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.grid_square = nil
      expect(@repeater_search).to be_valid
      @repeater_search.grid_square = "FN22"
      expect(@repeater_search).to be_valid
      @repeater_search.grid_square = "FN22ab"
      expect(@repeater_search).to be_valid
    end
  end

  context "When geosearching by coordinates" do
    before do
      @repeater_search = create(:repeater_search,
        geosearch_type: RepeaterSearch::COORDINATES,
        distance: 10, distance_unit: RepeaterSearch::KM,
        latitude: 10.01, longitude: 20.02)
      expect(@repeater_search).to be_valid
    end

    it "validates distance" do
      # Distance can neither be missing nor be invalid.
      @repeater_search.distance = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance = nil
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance = 10
      expect(@repeater_search).to be_valid
    end

    it "validates distance unit" do
      # Distance unit can neither be missing nor be invalid.
      @repeater_search.distance_unit = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance_unit = nil
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance_unit = RepeaterSearch::KM
      expect(@repeater_search).to be_valid
    end

    it "doesn't validate place" do
      # Place can be missing.
      @repeater_search.place = nil
      expect(@repeater_search).to be_valid
      @repeater_search.place = ""
      expect(@repeater_search).to be_valid
      @repeater_search.place = "New York, NY, US"
      expect(@repeater_search).to be_valid
    end

    it "validates latitude" do
      # Latitude can be missing but not invalid.
      @repeater_search.latitude = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.latitude = nil
      expect(@repeater_search).to_not be_valid
      @repeater_search.latitude = 10.01
      expect(@repeater_search).to be_valid
    end

    it "validates longitude" do
      # Longitude can neither be missing nor be invalid.
      @repeater_search.longitude = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.longitude = nil
      expect(@repeater_search).to_not be_valid
      @repeater_search.longitude = 20.02
      expect(@repeater_search).to be_valid
    end

    it "validates grid square" do
      # Grid square can be missing but not invalid.
      @repeater_search.grid_square = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.grid_square = nil
      expect(@repeater_search).to be_valid
      @repeater_search.grid_square = "FN22"
      expect(@repeater_search).to be_valid
      @repeater_search.grid_square = "FN22ab"
      expect(@repeater_search).to be_valid
    end
  end

  context "When geosearching by grid square" do
    before do
      @repeater_search = create(:repeater_search,
        geosearch_type: RepeaterSearch::GRID_SQUARE,
        distance: 10, distance_unit: RepeaterSearch::KM,
        grid_square: "FN22ab")
      expect(@repeater_search).to be_valid
    end

    it "validates distance" do
      # Distance can neither be missing nor be invalid.
      @repeater_search.distance = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance = nil
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance = 10
      expect(@repeater_search).to be_valid
    end

    it "validates distance unit" do
      # Distance unit can neither be missing nor be invalid.
      @repeater_search.distance_unit = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance_unit = nil
      expect(@repeater_search).to_not be_valid
      @repeater_search.distance_unit = RepeaterSearch::KM
      expect(@repeater_search).to be_valid
    end

    it "doesn't validate place" do
      # Place can be missing.
      @repeater_search.place = nil
      expect(@repeater_search).to be_valid
      @repeater_search.place = ""
      expect(@repeater_search).to be_valid
      @repeater_search.place = "New York, NY, US"
      expect(@repeater_search).to be_valid
    end

    it "validates latitude" do
      # Latitude can be missing but not invalid.
      @repeater_search.latitude = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.latitude = nil
      expect(@repeater_search).to be_valid
      @repeater_search.latitude = 10.01
      expect(@repeater_search).to be_valid
    end

    it "validates longitude" do
      # Longitude can be missing but not invalid.
      @repeater_search.longitude = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.longitude = nil
      expect(@repeater_search).to be_valid
      @repeater_search.longitude = 20.02
      expect(@repeater_search).to be_valid
    end

    it "validates grid square" do
      # Grid square can neither be missing nor be invalid.
      @repeater_search.grid_square = "invalid"
      expect(@repeater_search).to_not be_valid
      @repeater_search.grid_square = nil
      expect(@repeater_search).to_not be_valid
      @repeater_search.grid_square = "FN22"
      expect(@repeater_search).to be_valid
      @repeater_search.grid_square = "FN22ab"
      expect(@repeater_search).to be_valid
    end
  end

  it "should not run search when it's invalid" do
    repeater_search = create(:repeater_search)
    repeater_search.geosearch_type = RepeaterSearch::COORDINATES
    expect { repeater_search.run }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "should blank coordinates when geolocation fails" do
    Geocoder::Lookup::Test.add_stub("New York, NY, US",
      [{"coordinates" => [40.7143528, -74.0059731],
        "address" => "New York, NY, USA",
        "state" => "New York",
        "state_code" => "NY",
        "country" => "United States",
        "country_code" => "US"}])
    Geocoder::Lookup::Test.add_stub("Nowhere", [])
    @repeater_search = create(:repeater_search,
      geosearch_type: RepeaterSearch::PLACE,
      distance: 10, distance_unit: RepeaterSearch::KM,
      place: "New York, NY, US")
    expect(@repeater_search).to be_valid

    @repeater_search.place = "Nowhere"
    expect(@repeater_search).to_not be_valid
    expect(@repeater_search.latitude).to be_nil
    expect(@repeater_search.longitude).to be_nil
  end

  it "should generate names" do
    repeater_search = build(:repeater_search)
    repeater_search.generate_name
    expect(repeater_search.name).to eq("All modes on all bands")

    repeater_search = build(:repeater_search)
    repeater_search.fm = true
    repeater_search.dstar = true
    repeater_search.generate_name
    expect(repeater_search.name).to eq("FM and D-Star on all bands")

    repeater_search = build(:repeater_search)
    repeater_search.band_2m = true
    repeater_search.band_70cm = true
    repeater_search.generate_name
    expect(repeater_search.name).to eq("All modes on 2m and 70cm")

    repeater_search = build(:repeater_search, geosearch_type: RepeaterSearch::MY_LOCATION,
      distance: 10, distance_unit: RepeaterSearch::KM,
      latitude: 10.01, longitude: 20.02)
    repeater_search.generate_name
    expect(repeater_search.name).to eq("All modes on all bands within 10km of my location (10.0, 20.0)")

    repeater_search = build(:repeater_search, geosearch_type: RepeaterSearch::MY_LOCATION,
      distance: 10, distance_unit: RepeaterSearch::KM)
    repeater_search.generate_name
    expect(repeater_search.name).to eq("All modes on all bands within 10km of my location")

    repeater_search = build(:repeater_search,
      geosearch_type: RepeaterSearch::PLACE,
      distance: 10, distance_unit: RepeaterSearch::KM,
      place: "New York, NY, US")
    repeater_search.generate_name
    expect(repeater_search.name).to eq("All modes on all bands within 10km of New York, NY, US")
    Geocoder::Lookup::Test.add_stub("New York, NY, US",
      [{"coordinates" => [40.7143528, -74.0059731],
        "address" => "New York, NY, USA",
        "state" => "New York",
        "state_code" => "NY",
        "country" => "United States",
        "country_code" => "US"}])
    repeater_search.save!
    repeater_search.generate_name
    expect(repeater_search.name).to eq("All modes on all bands within 10km of New York, NY, US (40.7, -74.0)")

    repeater_search = build(:repeater_search,
      geosearch_type: RepeaterSearch::COORDINATES,
      distance: 10, distance_unit: RepeaterSearch::KM)
    repeater_search.generate_name
    expect(repeater_search.name).to eq("All modes on all bands within 10km of coordinates")

    repeater_search = build(:repeater_search,
      geosearch_type: RepeaterSearch::COORDINATES,
      distance: 10, distance_unit: RepeaterSearch::KM,
      latitude: 10.01, longitude: 20.02)
    repeater_search.generate_name
    expect(repeater_search.name).to eq("All modes on all bands within 10km of coordinates 10.01, 20.02")

    repeater_search = build(:repeater_search,
      geosearch_type: RepeaterSearch::GRID_SQUARE,
      distance: 10, distance_unit: RepeaterSearch::KM,
      grid_square: "FN22ab")
    repeater_search.generate_name
    expect(repeater_search.name).to eq("All modes on all bands within 10km of grid square FN22ab")
    repeater_search.save!
    repeater_search.generate_name
    expect(repeater_search.name).to eq("All modes on all bands within 10km of grid square FN22ab (42.1, -76.0)")

    repeater_search = build(:repeater_search,
      geosearch_type: RepeaterSearch::WITHIN_A_COUNTRY,
      country: Country.find("gb"))
    repeater_search.generate_name
    expect(repeater_search.name).to eq("All modes on all bands within United Kingdom")

    repeater_search = build(:repeater_search, search_terms: "london")
    repeater_search.generate_name
    expect(repeater_search.name).to eq("All modes on all bands containing \"london\"")
  end
end
