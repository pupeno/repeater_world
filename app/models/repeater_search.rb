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

class RepeaterSearch < ApplicationRecord
  # TODO: geolocate the IP of the user and select the appropriate country

  DISTANCE_UNITS = [
    KM = "km",
    MILES = "miles"
  ]

  # Bands that are supported during search.
  BANDS = [
    BAND_10M = {label: "10m", secondary: true},
    BAND_6M = {label: "6m", secondary: true},
    BAND_4M = {label: "4m", secondary: true},
    BAND_2M = {label: "2m", secondary: false},
    BAND_1_25M = {label: "1.25m", secondary: true},
    BAND_70CM = {label: "70cm", secondary: false},
    BAND_33CM = {label: "33cm", secondary: true},
    BAND_23CM = {label: "23cm", secondary: true},
    BAND_13CM = {label: "13cm", secondary: true},
    BAND_9CM = {label: "9cm", secondary: true},
    BAND_6CM = {label: "6cm", secondary: true},
    BAND_3CM = {label: "3cm", secondary: true}
  ]
  BANDS.each do |band|
    band[:symbol] = :"#{band[:label]}"
    band[:name] = :"band_#{band[:label].tr(".", "_")}"
    band[:pred] = :"#{band[:name]}?"
  end

  # Modes that are supported during search.
  MODES = [
    FM = {label: "FM", name: :fm, secondary: false},
    DSTAR = {label: "D-Star", name: :dstar, secondary: false},
    FUSION = {label: "Fusion", name: :fusion, secondary: true},
    DMR = {label: "DMR", name: :dmr, secondary: true},
    NXDN = {label: "NXDN", name: :nxdn, secondary: true},
    P25 = {label: "P25", name: :p25, secondary: true},
    TETRA = {label: "TETRA", name: :tetra, secondary: true}
  ]
  MODES.each do |mode|
    mode[:symbol] = :"#{mode[:name]}"
    mode[:pred] = :"#{mode[:name]}?"
  end
  MULTI_MODE = {label: "Multi", symbol: :multi}
  MODES_AND_MULTI = [MULTI_MODE] + MODES

  GEOSEARCH_TYPES = [
    MY_LOCATION = "my_location",
    COORDINATES = "coordinates",
    GRID_SQUARE = "grid_square",
    PLACE = "place",
    WITHIN_A_COUNTRY = "within_a_country"
  ]

  attr_writer :saving

  belongs_to :user, optional: true
  belongs_to :country, optional: true

  validates :user, presence: true, if: :saving
  validates :name, presence: true, if: :saving
  validates :distance, presence: true, if: :distance_required?
  validates :distance, numericality: {greater_than: 0}, allow_blank: true
  validates :distance_unit, presence: true, if: :distance_required?
  validates :distance_unit, inclusion: DISTANCE_UNITS, allow_blank: true
  validates :place, presence: true, if: :place_required?
  validates :latitude, presence: true, if: :lat_and_long_required?
  validates :latitude, numericality: true, allow_blank: true
  validates :longitude, presence: true, if: :lat_and_long_required?
  validates :longitude, numericality: true, allow_blank: true
  validates :grid_square, presence: true, if: :grid_square_required?
  validate :grid_square_format_valid

  after_validation :geosearch_post_processing

  def run
    orig_saving = saving
    self.saving = false
    invalid = !valid?
    self.saving = orig_saving
    if invalid
      raise ActiveRecord::RecordInvalid.new(self)
    end

    repeaters = if search_terms.present?
      PgSearch.multisearch(search_terms)
    else
      PgSearch::Document
    end

    bands = BANDS.filter { |band| send(band[:pred]) }.map { |band| band[:label] }
    repeaters = repeaters.where(band: bands) if bands.present?

    modes = MODES.filter { |mode| send(mode[:pred]) }
    if modes.present?
      cond = PgSearch::Document.where(modes.first[:name] => true)
      modes[1..].each do |mode|
        cond = cond.or(PgSearch::Document.where(mode[:name] => true))
      end
      repeaters = repeaters.merge(cond)
    end

    if geosearch_type.in? [MY_LOCATION, COORDINATES, GRID_SQUARE, PLACE]
      repeaters = repeaters.select(self.class.sanitize_sql_array([<<-SQL, current_location: Geo.to_wkt(Geo.point(latitude, longitude))]))
        #{repeaters.table_name}.*,
        ST_Distance(:current_location, location) AS distance,
        degrees(ST_Azimuth(:current_location, location)) AS azimuth
      SQL
      distance = self.distance * ((distance_unit == RepeaterSearch::MILES) ? 1609.34 : 1000)
      repeaters = repeaters.where(
        "ST_DWithin(location, :point, :distance)",
        {point: Geo.to_wkt(Geo.point(latitude, longitude)),
         distance: distance}
      ).all
      repeaters = repeaters.order(:distance)
    elsif geosearch_type == WITHIN_A_COUNTRY
      repeaters = repeaters.where(country_id: country_id)
    end

    if search_terms.blank? # When there are search terms, we let full text search control the order.
      repeaters = repeaters.order(:name, :call_sign)
    end

    repeaters
  end

  def all_bands?
    BANDS.map { |band| !send(band[:pred]) }.all?
  end

  def all_modes?
    MODES.map { |mode| !send(mode[:pred]) }.all?
  end

  def geosearch?
    geosearch_type.present?
  end

  def distance_required?
    geosearch_type.in? [MY_LOCATION, COORDINATES, GRID_SQUARE, PLACE]
  end

  def place_required?
    geosearch_type == PLACE
  end

  def lat_and_long_required?
    geosearch_type.in? [COORDINATES, MY_LOCATION]
  end

  def grid_square_format_valid
    if grid_square.present? && !DX::Grid.valid?(grid_square)
      errors.add(:grid_square, "is not a valid grid square")
    end
  end

  def grid_square_required?
    geosearch_type == GRID_SQUARE
  end

  def geosearch_post_processing
    # If we are searching for my location and we didn't get valid latitude and longitude from the browser, add an error
    # to the geosearch_type field so that it's actually visible in the form.
    if geosearch_type == MY_LOCATION && (errors[:latitude].present? || errors[:longitude].present?)
      errors.add(:base, "We couldn't get valid coordinates for your location")
      errors.delete(:latitude)
      errors.delete(:longitude)
    end

    # If we are searching for a place, populate the lat and long.
    if geosearch_type == PLACE && errors[:place].blank? && place != place_was
      results = Geocoder.search(place).first
      if results.present?
        self.latitude = results.latitude
        self.longitude = results.longitude
      else
        self.latitude = nil
        self.longitude = nil
        errors.add(:place, "with that name, address or postcode couldn't be found")
      end
    end

    # If we are searching for grid square, populate the lat and long.
    if geosearch_type == GRID_SQUARE && errors[:grid_square].blank?
      self.latitude, self.longitude = DX::Grid.decode(grid_square)
    end
  end

  def saving
    @saving.nil? ? true : @saving
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
#  geosearch_type :string
#  grid_square    :string
#  latitude       :decimal(, )
#  longitude      :decimal(, )
#  name           :string
#  nxdn           :boolean          default(FALSE), not null
#  p25            :boolean          default(FALSE), not null
#  place          :string
#  search_terms   :string
#  tetra          :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  country_id     :string
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
