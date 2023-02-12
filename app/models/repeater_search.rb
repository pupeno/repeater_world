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

class RepeaterSearch < ApplicationRecord
  DISTANCE_UNITS = [
    KM = "km",
    MILES = "miles"
  ]

  belongs_to :user

  validates :distance, presence: true, if: :distance_to_coordinates?
  validates :distance_unit, presence: true, if: :distance_to_coordinates?
  validates :latitude, presence: true, if: :distance_to_coordinates?
  validates :longitude, presence: true, if: :distance_to_coordinates?
  validates :distance, numericality: {greater_than: 0}, allow_blank: true
  validates :distance_unit, inclusion: DISTANCE_UNITS, allow_blank: true
  validates :latitude, numericality: true, allow_blank: true
  validates :longitude, numericality: true, allow_blank: true

  def run
    repeaters = Repeater

    bands = Repeater::BANDS.filter { |band| send(:"band_#{band}?") }
    repeaters = repeaters.where(band: bands) if bands.present?

    modes = Repeater::MODES.filter { |mode| send(:"#{mode}?") }
    if modes.present?
      cond = Repeater.where(modes.first => true)
      modes[1..].each do |mode|
        cond = cond.or(Repeater.where(mode => true))
      end
      repeaters = repeaters.merge(cond)
    end

    if distance_to_coordinates?
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
end

# == Schema Information
#
# Table name: repeater_searches
#
#  id                      :uuid             not null, primary key
#  band_10m                :boolean
#  band_23cm               :boolean
#  band_2m                 :boolean
#  band_4m                 :boolean
#  band_6m                 :boolean
#  band_70cm               :boolean
#  distance                :integer
#  distance_to_coordinates :boolean
#  distance_unit           :string
#  dmr                     :boolean
#  dstar                   :boolean
#  fm                      :boolean
#  fusion                  :boolean
#  latitude                :decimal(, )
#  longitude               :decimal(, )
#  nxdn                    :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :uuid
#
# Indexes
#
#  index_repeater_searches_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
