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

RSpec.describe Repeater, type: :model do
  context "A repeater" do
    before { @repeater = create(:repeater) }

    it "is readable" do
      expect(@repeater.to_s).to include(@repeater.class.name)
      expect(@repeater.to_s).to include(@repeater.id)
      expect(@repeater.to_s).to include(@repeater.name)
      expect(@repeater.to_s).to include(@repeater.call_sign)
    end

    it "fixes web site" do
      @repeater.web_site = "example.com"
      expect(@repeater.web_site).to eq("http://example.com")
      @repeater.web_site = nil
      expect(@repeater.web_site).to eq(nil)
      @repeater.web_site = ""
      expect(@repeater.web_site).to eq("")
      @repeater.web_site = "  "
      expect(@repeater.web_site).to eq("  ")
      @repeater.web_site = "http:example.com"
      expect(@repeater.web_site).to eq("http://http:example.com") # Can't save everyone.
    end

    it "updates slug" do
      expect(@repeater.should_generate_new_friendly_id?).to eq(false)
      expect(@repeater.slug).to eq("bl4nk-repeater-bl4nk-2m")

      @repeater.slug = ""
      expect(@repeater.should_generate_new_friendly_id?).to eq(true)

      @repeater.slug = " "
      expect(@repeater.should_generate_new_friendly_id?).to eq(true)

      @repeater.slug = nil
      expect(@repeater.should_generate_new_friendly_id?).to eq(true)
    end

    it "has input coordinates" do
      @repeater.input_coordinates = nil
      expect(@repeater.input_coordinates).to eq(nil)
      expect(@repeater.input_latitude).to eq(nil)
      expect(@repeater.input_longitude).to eq(nil)
      @repeater.input_latitude = 10
      expect(@repeater.input_coordinates).to eq(nil)
      expect(@repeater.input_latitude).to eq(nil)
      expect(@repeater.input_longitude).to eq(nil)
      @repeater.input_longitude = 20
      expect(@repeater.input_coordinates).to eq(Geo.point(10, 20))
      expect(@repeater.input_latitude).to eq(10)
      expect(@repeater.input_longitude).to eq(20)
      @repeater.save!
      @repeater.reload
      expect(@repeater.input_coordinates).to eq(Geo.point(10, 20))
      expect(@repeater.input_latitude).to eq(10)
      expect(@repeater.input_longitude).to eq(20)
    end

    it "has coordinates" do
      @repeater.coordinates = nil
      expect(@repeater.coordinates).to eq(nil)
      expect(@repeater.latitude).to eq(nil)
      expect(@repeater.longitude).to eq(nil)
      @repeater.latitude = 10
      expect(@repeater.coordinates).to eq(nil)
      expect(@repeater.latitude).to eq(nil)
      expect(@repeater.longitude).to eq(nil)
      @repeater.longitude = 20
      expect(@repeater.coordinates).to eq(Geo.point(10, 20))
      expect(@repeater.latitude).to eq(10)
      expect(@repeater.longitude).to eq(20)
    end

    context "while geocoding" do
      before(:each) do
        Geocoder::Lookup::Test.reset
        @start = Time.now
      end

      it "should compute blank locations" do
        @repeater.input_address = nil
        @repeater.input_locality = nil
        @repeater.input_region = nil
        @repeater.input_post_code = nil
        @repeater.input_country_id = nil
        @repeater.input_coordinates = nil
        @repeater.input_grid_square = nil

        @repeater.save!

        expect(@repeater.address).to eq(nil)
        expect(@repeater.locality).to eq(nil)
        expect(@repeater.region).to eq(nil)
        expect(@repeater.post_code).to eq(nil)
        expect(@repeater.country_id).to eq(nil)
        expect(@repeater.coordinates).to eq(nil)
        expect(@repeater.grid_square).to eq(nil)
      end

      it "should compute from address" do
        Geocoder::Lookup::Test.add_stub("225 Main Street, Newington, Connecticut, 06111, United States",
          [
            {
              "coordinates" => [40.7143528, -74.0059731],
              "address" => "225 Main Street, Newington, Connecticut, 06111, United States",
              "state" => "Connecticut",
              "state_code" => "CT",
              "country" => "United States",
              "country_code" => "US"
            }
          ])

        @repeater.input_address = "225 Main Street"
        @repeater.input_locality = "Newington"
        @repeater.input_region = "Connecticut"
        @repeater.input_post_code = "06111"
        @repeater.input_country_id = "us"
        @repeater.input_coordinates = nil
        @repeater.input_grid_square = nil

        @repeater.save!

        expect(@repeater.address).to eq("225 Main Street")
        expect(@repeater.locality).to eq("Newington")
        expect(@repeater.region).to eq("Connecticut")
        expect(@repeater.post_code).to eq("06111")
        expect(@repeater.country_id).to eq("us")
        expect(@repeater.latitude).to eq(40.7143528)
        expect(@repeater.longitude).to eq(-74.0059731)
        expect(@repeater.grid_square).to eq("FN20xr")
      end

      it "should attempt to compute from address even when failing" do
        Geocoder::Lookup::Test.add_stub("225 Main Street, Newington, Connecticut, 06111, United States", [])

        @repeater.input_address = "225 Main Street"
        @repeater.input_locality = "Newington"
        @repeater.input_region = "Connecticut"
        @repeater.input_post_code = "06111"
        @repeater.input_country_id = "us"
        @repeater.input_coordinates = nil
        @repeater.input_grid_square = nil
        @repeater.save!

        expect(@repeater.address).to eq("225 Main Street")
        expect(@repeater.locality).to eq("Newington")
        expect(@repeater.region).to eq("Connecticut")
        expect(@repeater.post_code).to eq("06111")
        expect(@repeater.country_id).to eq("us")
        expect(@repeater.coordinates).to eq(nil)
        expect(@repeater.grid_square).to eq(nil)
        expect(@repeater.geocoded_at).to be > @start
        expect(@repeater.geocoded_by).to eq("NilClass")
      end

      it "should compute from fixed coordinates" do
        Geocoder::Lookup::Test.add_stub("225 Main Street, Newington, Connecticut, 06111, US",
          [
            {
              "coordinates" => [40.7143528, -74.0059731],
              "address" => "225 Main Street, Newington, Connecticut, 06111, US",
              "state" => "Connecticut",
              "state_code" => "CT",
              "country" => "United States",
              "country_code" => "US"
            }
          ])

        @repeater.input_address = "225 Main Street"
        @repeater.input_locality = "Newington"
        @repeater.input_region = "Connecticut"
        @repeater.input_post_code = "06111"
        @repeater.input_country_id = "us"
        @repeater.input_latitude = 11 # Made up coordinates
        @repeater.input_longitude = 12
        @repeater.input_grid_square = nil

        @repeater.save!

        expect(@repeater.address).to eq("225 Main Street")
        expect(@repeater.locality).to eq("Newington")
        expect(@repeater.region).to eq("Connecticut")
        expect(@repeater.post_code).to eq("06111")
        expect(@repeater.country_id).to eq("us")
        expect(@repeater.latitude).to eq(11)
        expect(@repeater.longitude).to eq(12)
        expect(@repeater.grid_square).to eq("JK61aa")
        expect(@repeater.geocoded_at).to eq(nil)
        expect(@repeater.geocoded_by).to eq(nil)
      end

      it "should compute from grid square" do
        @repeater.input_address = nil
        @repeater.input_locality = nil
        @repeater.input_region = nil
        @repeater.input_post_code = nil
        @repeater.input_country_id = nil
        @repeater.input_coordinates = nil
        @repeater.input_grid_square = "JK61aa"

        @repeater.save!

        expect(@repeater.address).to eq(nil)
        expect(@repeater.locality).to eq(nil)
        expect(@repeater.region).to eq(nil)
        expect(@repeater.post_code).to eq(nil)
        expect(@repeater.country_id).to eq(nil)
        expect(@repeater.latitude).to eq(11.020833333333334)
        expect(@repeater.longitude).to eq(12.041666666666666)
        expect(@repeater.grid_square).to eq("JK61aa")
        expect(@repeater.geocoded_at).to eq(nil)
        expect(@repeater.geocoded_by).to eq(nil)
      end

      it "should override location with inputs" do
        @repeater.input_address = nil
        @repeater.input_locality = nil
        @repeater.input_region = nil
        @repeater.input_post_code = nil
        @repeater.input_country_id = nil
        @repeater.input_coordinates = nil
        @repeater.input_grid_square = nil
        @repeater.address = "225 Main Street"
        @repeater.locality = "Newington"
        @repeater.region = "Connecticut"
        @repeater.post_code = "06111"
        @repeater.country_id = "us"
        @repeater.latitude = 11
        @repeater.longitude = 12
        @repeater.grid_square = "JK61aa"

        @repeater.save!

        expect(@repeater.address).to eq(nil)
        expect(@repeater.locality).to eq(nil)
        expect(@repeater.region).to eq(nil)
        expect(@repeater.post_code).to eq(nil)
        expect(@repeater.country_id).to eq(nil)
        expect(@repeater.coordinates).to eq(nil)
        expect(@repeater.grid_square).to eq(nil)
      end
    end
  end
end

# == Schema Information
#
# Table name: repeaters
#
#  id                         :uuid             not null, primary key
#  address                    :string
#  altitude_agl               :integer
#  altitude_asl               :integer
#  band                       :string
#  bandwidth                  :integer
#  bearing                    :string
#  call_sign                  :string
#  channel                    :string
#  coordinates                :geography        point, 4326
#  dmr                        :boolean
#  dmr_color_code             :integer
#  dmr_network                :string
#  dstar                      :boolean
#  dstar_port                 :string
#  echo_link                  :boolean
#  echo_link_node_number      :integer
#  fm                         :boolean
#  fm_ctcss_tone              :decimal(, )
#  fm_tone_burst              :boolean
#  fm_tone_squelch            :boolean
#  fusion                     :boolean
#  geocoded_at                :datetime
#  geocoded_by                :string
#  grid_square                :string
#  input_address              :string
#  input_coordinates          :geography        point, 4326
#  input_grid_square          :string
#  input_locality             :string
#  input_post_code            :string
#  input_region               :string
#  keeper                     :string
#  locality                   :string
#  m17                        :boolean
#  m17_can                    :integer
#  m17_reflector_name         :string
#  name                       :string
#  notes                      :text
#  nxdn                       :boolean
#  operational                :boolean
#  p25                        :boolean
#  post_code                  :string
#  redistribution_limitations :string
#  region                     :string
#  rx_antenna                 :string
#  rx_antenna_polarization    :string
#  rx_frequency               :bigint           not null
#  slug                       :string           not null
#  source                     :string
#  tetra                      :boolean
#  tx_antenna                 :string
#  tx_antenna_polarization    :string
#  tx_frequency               :bigint           not null
#  tx_power                   :integer
#  utc_offset                 :string
#  web_site                   :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  country_id                 :string
#  external_id                :string
#  geocoded_country_id        :string
#  input_country_id           :string
#  wires_x_node_id            :string
#
# Indexes
#
#  index_repeaters_on_call_sign          (call_sign)
#  index_repeaters_on_coordinates        (coordinates) USING gist
#  index_repeaters_on_country_id         (country_id)
#  index_repeaters_on_input_coordinates  (input_coordinates)
#  index_repeaters_on_input_country_id   (input_country_id)
#  index_repeaters_on_slug               (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (input_country_id => countries.id)
#
