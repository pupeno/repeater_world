# Copyright 2023, Pablo Fernandez
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
      @repeater_search = create(:repeater_search, geosearch: false)
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
        geosearch: true, geosearch_type: RepeaterSearch::MY_LOCATION,
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
      expect(@repeater_search.errors[:geosearch_type]).to include("couldn't get valid coordinates for your location")
      @repeater_search.latitude = nil
      expect(@repeater_search).to_not be_valid
      expect(@repeater_search.errors[:geosearch_type]).to include("couldn't get valid coordinates for your location")
      @repeater_search.latitude = 10.01
      expect(@repeater_search).to be_valid
    end

    it "validates longitude" do
      # Longitude can neither be missing nor be invalid.
      @repeater_search.longitude = "invalid"
      expect(@repeater_search).to_not be_valid
      expect(@repeater_search.errors[:geosearch_type]).to include("couldn't get valid coordinates for your location")
      @repeater_search.longitude = nil
      expect(@repeater_search).to_not be_valid
      expect(@repeater_search.errors[:geosearch_type]).to include("couldn't get valid coordinates for your location")
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
        geosearch: true, geosearch_type: RepeaterSearch::PLACE,
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
        geosearch: true, geosearch_type: RepeaterSearch::COORDINATES,
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
        geosearch: true, geosearch_type: RepeaterSearch::GRID_SQUARE,
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
    repeater_search.geosearch = true
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
      geosearch: true, geosearch_type: RepeaterSearch::PLACE,
      distance: 10, distance_unit: RepeaterSearch::KM,
      place: "New York, NY, US")
    expect(@repeater_search).to be_valid

    @repeater_search.place = "Nowhere"
    expect(@repeater_search).to_not be_valid
    expect(@repeater_search.latitude).to be_nil
    expect(@repeater_search.longitude).to be_nil
  end
end

# == Schema Information
#
# Table name: repeater_searches
#
#  id             :uuid             not null, primary key
#  band_10m       :boolean          default(FALSE), not null
#  band_13cm      :boolean          default(FALSE), not null
#  band_1_25m     :boolean          default(FALSE), not null
#  band_23cm      :boolean          default(FALSE), not null
#  band_2m        :boolean          default(FALSE), not null
#  band_33cm      :boolean          default(FALSE), not null
#  band_3cm       :boolean          default(FALSE), not null
#  band_4m        :boolean          default(FALSE), not null
#  band_6cm       :boolean          default(FALSE), not null
#  band_6m        :boolean          default(FALSE), not null
#  band_70cm      :boolean          default(FALSE), not null
#  band_9cm       :boolean          default(FALSE), not null
#  distance       :integer
#  distance_unit  :string
#  dmr            :boolean          default(FALSE), not null
#  dstar          :boolean          default(FALSE), not null
#  fm             :boolean          default(FALSE), not null
#  fusion         :boolean          default(FALSE), not null
#  geosearch      :boolean
#  geosearch_type :string
#  grid_square    :string
#  latitude       :decimal(, )
#  longitude      :decimal(, )
#  name           :string
#  nxdn           :boolean          default(FALSE), not null
#  p25            :boolean          default(FALSE), not null
#  place          :string
#  tetra          :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :uuid
#
# Indexes
#
#  index_repeater_searches_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
