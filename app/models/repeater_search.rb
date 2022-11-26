class RepeaterSearch < ApplicationRecord
  DISTANCE_UNITS = [
    KM = "km",
    MILES = "miles"
  ]

  validates :distance, presence: true, if: :distance_to_coordinates?
  validates :distance_unit, presence: true, if: :distance_to_coordinates?
  validates :latitude, presence: true, if: :distance_to_coordinates?
  validates :longitude, presence: true, if: :distance_to_coordinates?
  validates :distance, numericality: { greater_than: 0 }, allow_blank: true
  validates :distance_unit, inclusion: DISTANCE_UNITS, allow_blank: true
  validates :latitude, numericality: true, allow_blank: true
  validates :longitude, numericality: true, allow_blank: true
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
#
