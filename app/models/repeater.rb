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

class Repeater < ApplicationRecord
  BANDS = [
    BAND_10M = "10m",
    BAND_6M = "6m",
    BAND_4M = "4m",
    BAND_2M = "2m",
    BAND_70CM = "70cm",
    BAND_23CM = "23cm"
  ]

  MODES = %w[fm dstar fusion dmr nxdn]

  ACCESS_METHODS = [
    TONE_BURST = "tone_burst",
    CTCSS = "ctcss"
  ]

  # Call this CTCSS tones.
  CTCSS_TONES = [
    67.0, 69.3, 71.9, 74.4, 77.0, 79.7, 82.5, 85.4, 88.5, 91.5, 94.8, 97.4, 100.0, 103.5, 107.2, 110.9, 114.8, 118.8,
    123, 127.3, 131.8, 136.5, 141.3, 146.2, 151.4, 156.7, 162.2, 167.9, 173.8, 179.9, 186.2, 192.8, 203.5, 210.7, 218.1,
    225.7, 233.6, 241.8, 250.3
  ]

  DMR_COLOR_CODES = (0..15).to_a

  belongs_to :country

  validates :name, presence: true
  validates :band, presence: true, inclusion: BANDS
  validates :tx_frequency, presence: true # TODO: validate the frequency is within the band: https://github.com/flexpointtech/repeater_world/issues/20
  validates :rx_frequency, presence: true # TODO: validate the frequency is within the band: https://github.com/flexpointtech/repeater_world/issues/20
  validates :access_method, inclusion: ACCESS_METHODS, allow_blank: true
  validates :ctcss_tone,
    presence: {if: lambda { |r| r.access_method == CTCSS }},
    inclusion: {in: CTCSS_TONES, if: lambda { |r| r.access_method == CTCSS }}

  def to_s(extra = nil)
    super("#{name}:#{call_sign}")
  end

  def latitude
    location&.latitude
  end

  def latitude=(value)
    self.location = Geo.point(value, longitude || 0)
  end

  def longitude
    location&.longitude
  end

  def longitude=(value)
    self.location = Geo.point(latitude || 0, value)
  end

  def modes
    modes = []
    modes << "FM" if fm?
    modes << "D-Star" if dstar?
    modes << "Fusion" if fusion?
    modes << "DMR" if dmr?
    modes << "NXDN" if nxdn?
    modes
  end

  def tx_frequency_in_mhz
    "#{tx_frequency / (10**6)}MHz"
  end

  def rx_frequency_in_mhz
    "#{rx_frequency / (10**6)}MHz"
  end

  def rx_offset_in_khz
    sign = (rx_frequency - tx_frequency > 0) ? "+" : "" # Artificially adding the +, because the int 600 renders as 600, not +600
    raw_offset = ((rx_frequency - tx_frequency) / (10**3)).to_i
    "#{sign}#{raw_offset}kHz"
  end

  def location_in_words
    [region_1, region_2, region_3, region_4, country.name].reject(&:blank?).join(", ")
  end

  def to_param
    "#{id}-#{call_sign.parameterize}-#{name.parameterize}"
  end

  rails_admin do
    list do
      field :country
      field :name
      field :call_sign
      field :band
      field :tx_frequency
      field :fm
      field :dstar
      field :fusion
      field :dmr
      field :nxdn
      field :source
    end
  end
end

# == Schema Information
#
# Table name: repeaters
#
#  id                         :uuid             not null, primary key
#  access_method              :string
#  band                       :string
#  call_sign                  :string
#  channel                    :string
#  ctcss_tone                 :decimal(, )
#  dmr                        :boolean
#  dmr_cc                     :integer
#  dmr_con                    :string
#  dstar                      :boolean
#  fm                         :boolean
#  fusion                     :boolean
#  grid_square                :string
#  keeper                     :string
#  location                   :geography        point, 4326
#  name                       :string
#  notes                      :text
#  nxdn                       :boolean
#  operational                :boolean
#  redistribution_limitations :string
#  region_1                   :string
#  region_2                   :string
#  region_3                   :string
#  region_4                   :string
#  rx_frequency               :decimal(, )
#  source                     :string
#  tone_sql                   :boolean
#  tx_frequency               :decimal(, )
#  utc_offset                 :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  country_id                 :string
#
# Indexes
#
#  index_repeaters_on_call_sign   (call_sign)
#  index_repeaters_on_country_id  (country_id)
#  index_repeaters_on_location    (location) USING gist
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
