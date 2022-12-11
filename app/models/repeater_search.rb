class RepeaterSearch < ApplicationRecord
  DISTANCE_UNITS = [
    KM = "km",
    MILES = "miles"
  ]

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

    bands = Repeater::BANDS.filter { |band| self.send(:"band_#{band}?") }
    repeaters = repeaters.where(band: bands) if bands.present?

    modes = Repeater::MODES.filter { |mode| self.send(:"#{mode}?") }
    if modes.present?
      cond = Repeater.where(modes.first => true)
      modes[1..]&.each do |mode|
        cond = cond.or(Repeater.where(mode => true))
      end
      repeaters = repeaters.merge(cond)
    end

    if self.distance_to_coordinates?
      distance = self.distance * ((self.distance_unit == RepeaterSearch::MILES) ? 1609.34 : 1000)
      repeaters = repeaters.where(
        "ST_DWithin(location, :point, :distance)",
        {point: Geo.to_wkt(Geo.point(self.latitude, self.longitude)),
         distance: distance}
      ).all
    end

    repeaters.all
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
#
