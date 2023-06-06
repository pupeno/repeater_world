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

class Repeater < ApplicationRecord
  BANDS = [
    BAND_10M = "10m",
    BAND_6M = "6m",
    BAND_4M = "4m",
    BAND_2M = "2m",
    BAND_1_25M = "1.25m",
    BAND_70CM = "70cm",
    BAND_33CM = "33cm",
    BAND_23CM = "23cm",
    BAND_13CM = "13cm",
    BAND_9CM = "9cm",
    BAND_6CM = "6cm",
    BAND_3CM = "3cm"
  ]

  # These are a mix of various band plans to ensure coverage. It can be expanded to cover more regions.
  BAND_FREQUENCIES = [
    {min: 28_000_000, max: 29_700_000, band: BAND_10M},
    {min: 50_000_000, max: 54_000_000, band: BAND_6M},
    {min: 70_000_000, max: 70_500_000, band: BAND_4M},
    {min: 144_000_000, max: 148_000_000, band: BAND_2M},
    {min: 222_000_000, max: 225_000_000, band: BAND_1_25M},
    {min: 420_000_000, max: 450_000_000, band: BAND_70CM},
    {min: 902_000_000, max: 928_000_000, band: BAND_33CM},
    {min: 1_240_000_000, max: 1_300_000_000, band: BAND_23CM},
    {min: 2_300_000_000, max: 2_450_000_000, band: BAND_13CM},
    {min: 3_300_000_000, max: 3_600_000_000, band: BAND_9CM},
    {min: 5_650_000_000, max: 5_850_000_000, band: BAND_6CM},
    {min: 10_000_000_000, max: 10_500_000_000, band: BAND_3CM}
  ]

  MODES = %w[fm nfm dstar fusion dmr nxdn p25 tetra]

  CTCSS_TONES = [
    67.0, 69.3, 71.9, 74.4, 77.0, 79.7, 82.5, 85.4, 88.5, 91.5, 94.8, 97.4, 100.0, 103.5, 107.2, 110.9, 114.8, 118.8,
    123, 127.3, 131.8, 136.5, 141.3, 146.2, 151.4, 156.7, 162.2, 167.9, 173.8, 179.9, 186.2, 192.8, 203.5, 210.7, 218.1,
    225.7, 233.6, 241.8, 250.3
  ]

  DMR_COLOR_CODES = (0..15).to_a

  belongs_to :country

  validates :name, presence: true
  validates :call_sign, presence: true
  validates :band, presence: true, inclusion: BANDS
  validates :tx_frequency, presence: true # TODO: validate the frequency is within the band: https://github.com/pupeno/repeater_world/issues/20
  validates :rx_frequency, presence: true # TODO: validate the frequency is within the band: https://github.com/pupeno/repeater_world/issues/20
  validates :fm_ctcss_tone, inclusion: CTCSS_TONES, allow_blank: true
  validates :dmr_color_code, inclusion: DMR_COLOR_CODES, allow_blank: true

  before_validation :ensure_band_is_set

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
    modes = Set.new
    modes << :fm if fm?
    modes << :nfm if nfm?
    modes << :dstar if dstar?
    modes << :fusion if fusion?
    modes << :dmr if dmr?
    modes << :nxdn if nxdn?
    modes << :p25 if p25?
    modes << :tetra if tetra?
    modes
  end

  def location_in_words
    [address, locality, region, post_code, country.name].reject(&:blank?).join(", ")
  end

  def to_param
    [id, call_sign&.parameterize, name&.parameterize].reject(&:blank?).join("-")
  end

  def web_site=(value)
    if value.present? && !value.start_with?("http://") && !value.start_with?("https://")
      value = "http://#{value}"
    end
    super(value)
  end

  def ensure_band_is_set
    if band.blank? && tx_frequency.present?
      BAND_FREQUENCIES.each do |band_frequency|
        if tx_frequency >= band_frequency[:min] && tx_frequency <= band_frequency[:max]
          self.band = band_frequency[:band]
          break
        end
      end
    end
  end

  rails_admin do
    list do
      field :country
      field :name
      field :call_sign
      field :band
      field :tx_frequency
      field :fm
      field :nfm
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
#  address                    :string
#  altitude_agl               :integer
#  altitude_asl               :integer
#  band                       :string
#  bearing                    :string
#  call_sign                  :string
#  channel                    :string
#  dmr                        :boolean
#  dmr_color_code             :integer
#  dmr_network                :string
#  dstar                      :boolean
#  dstar_port                 :string
#  fm                         :boolean
#  fm_ctcss_tone              :decimal(, )
#  fm_tone_burst              :boolean
#  fm_tone_squelch            :boolean
#  fusion                     :boolean
#  grid_square                :string
#  keeper                     :string
#  locality                   :string
#  location                   :geography        point, 4326
#  name                       :string
#  nfm                        :boolean
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
