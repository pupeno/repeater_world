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

class RepeaterSearch < ApplicationRecord
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
    band[:name] = :"band_#{band[:label].tr(".", "_")}"
    band[:pred] = :"#{band[:name]}?"
  end

  # Modes that are supported during search.
  MODES = [
    MODE_FM = {label: "FM", name: :fm, secondary: false},
    MODE_DSTAR = {label: "D-Star", name: :dstar, secondary: false},
    MODE_FUSION = {label: "Fusion", name: :fusion, secondary: false},
    MODE_DMR = {label: "DMR", name: :dmr, secondary: false},
    MODE_NXDN = {label: "NXDN", name: :nxdn, secondary: true},
    MODE_P25 = {label: "P25", name: :p25, secondary: true},
    MODE_TETRA = {label: "TETRA", name: :tetra, secondary: true}
  ]
  MODES.each do |mode|
    mode[:pred] = :"#{mode[:name]}?"
  end

  GEOSEARCH_TYPES = [
    GEOSEARCH_MY_LOCATION = "my_location",
    GEOSEARCH_COORDINATES = "coordinates"
  ]

  belongs_to :user

  validates :name, presence: true
  validates :distance, presence: true, if: :geosearch?
  validates :distance_unit, presence: true, if: :geosearch?
  validates :latitude, presence: true, if: :geosearch?
  validates :longitude, presence: true, if: :geosearch?
  validates :distance, numericality: {greater_than: 0}, allow_blank: true
  validates :distance_unit, inclusion: DISTANCE_UNITS, allow_blank: true
  validates :latitude, numericality: true, allow_blank: true
  validates :longitude, numericality: true, allow_blank: true

  def run
    repeaters = Repeater

    bands = BANDS.filter { |band| send(band[:pred]) }.map { |band| band[:label] }
    repeaters = repeaters.where(band: bands) if bands.present?

    modes = MODES.filter { |mode| send(mode[:pred]) }
    if modes.present?
      cond = Repeater.where(modes.first[:name] => true)
      modes[1..].each do |mode|
        cond = cond.or(Repeater.where(mode[:name] => true))
      end
      repeaters = repeaters.merge(cond)
    end

    if geosearch?
      distance = self.distance * ((distance_unit == RepeaterSearch::MILES) ? 1609.34 : 1000)
      repeaters = repeaters.where(
        "ST_DWithin(location, :point, :distance)",
        {point: Geo.to_wkt(Geo.point(latitude, longitude)),
         distance: distance}
      ).all
    end

    repeaters = repeaters.order(Arel.sql("
        case
            when \"repeaters\".\"operational\" = true then 1
            when \"repeaters\".\"operational\" IS NULL then 2
            when \"repeaters\".\"operational\" = false then 3
        end"))

    repeaters = repeaters.order("name, call_sign")

    repeaters.includes(:country)

    repeaters
  end

  def all_bands?
    BANDS.map { |band| !send(band[:pred]) }.all?
  end

  def all_modes?
    MODES.map { |mode| !send(mode[:pred]) }.all?
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
#  latitude       :decimal(, )
#  longitude      :decimal(, )
#  name           :string
#  nxdn           :boolean          default(FALSE), not null
#  p25            :boolean          default(FALSE), not null
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
