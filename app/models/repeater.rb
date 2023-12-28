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

  MODES = [
    FM = "fm",
    DSTAR = "dstar",
    FUSION = "fusion",
    DMR = "dmr",
    NXDN = "nxdn",
    P25 = "p25",
    TETRA = "tetra"
  ]

  CTCSS_TONES = [
    67.0, 69.3, 71.9, 74.4, 77.0, 79.7, 82.5, 85.4, 88.5, 91.5, 94.8, 97.4, 100.0, 103.5, 107.2, 110.9, 114.8, 118.8,
    123, 127.3, 131.8, 136.5, 141.3, 146.2, 151.4, 156.7, 162.2, 167.9, 173.8, 179.9, 186.2, 192.8, 203.5, 210.7, 218.1,
    225.7, 233.6, 241.8, 250.3
  ]

  FM_BANDWIDTHS = [
    FM_WIDE = "wide",
    FM_NARROW = "narrow"
  ]

  DMR_COLOR_CODES = (0..15).to_a

  belongs_to :country
  belongs_to :geocoded_country, class_name: "Country", optional: true

  validates :call_sign, presence: true
  validates :band, presence: true, inclusion: BANDS
  validates :tx_frequency, presence: true # TODO: validate the frequency is within the band: https://github.com/pupeno/repeater_world/issues/20
  validates :rx_frequency, presence: true # TODO: validate the frequency is within the band: https://github.com/pupeno/repeater_world/issues/20
  validates :fm_ctcss_tone, inclusion: CTCSS_TONES, allow_blank: true
  validates :fm_bandwidth, inclusion: FM_BANDWIDTHS, if: :fm?
  validates :dmr_color_code, inclusion: DMR_COLOR_CODES, allow_blank: true

  before_validation :ensure_fields_are_set

  def to_s(extra = nil)
    super("#{name}:#{call_sign}")
  end

  def name
    super || [locality, call_sign].compact.join(" ")
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
    Set.new MODES.select { |mode| send(:"#{mode}?") }.map(&:to_sym)
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

  def ensure_fields_are_set
    if band.blank? && tx_frequency.present?
      BAND_FREQUENCIES.each do |band_frequency|
        if tx_frequency >= band_frequency[:min] && tx_frequency <= band_frequency[:max]
          self.band = band_frequency[:band]
          break
        end
      end
    end
    if fm_bandwidth.blank? && fm?
      self.fm_bandwidth = FM_WIDE
    end
  end

  rails_admin do
    list do
      field :country
      field :name
      field :call_sign
      field :band
      field :operational
      field :tx_frequency
      field :fm
      field :dstar
      field :fusion
      field :dmr
    end

    show do
      group "Essentials" do
        field :name
        field :call_sign
        field :keeper
        field :notes
        field :web_site
        field :tx_frequency
        field :rx_frequency
        field :operational
        field :fm
        field :dstar
        field :fusion
        field :dmr
        field :nxdn
        field :p25
        field :tetra
      end

      group "FM" do
        field :fm_tone_burst
        field :fm_ctcss_tone
        field :fm_tone_squelch
      end

      group "D-Star" do
        field :dstar_port
      end

      group "DMR" do
        field :dmr_color_code
        field :dmr_network
      end

      group "Location" do
        field :latitude
        field :longitude
        field :address
        field :locality
        field :region
        field :post_code
        field :country
        field :grid_square
        field :utc_offset
      end

      group "Gocoding" do
        field :geocoded_at
        field :geocoded_address
        field :geocoded_locality
        field :geocoded_region
        field :geocoded_post_code
        field :geocoded_country
      end

      group "Source" do
        field :redistribution_limitations
        field :source
        field :external_id
      end

      group "Other" do
        field :tx_antenna
        field :tx_antenna_polarization
        field :tx_power
        field :rx_antenna
        field :rx_antenna_polarization
        field :altitude_agl
        field :altitude_asl
        field :bearing
        field :band
        field :channel
      end

      group "Record" do
        field :id
        field :created_at
        field :updated_at
      end
    end

    edit do
      group "Essentials" do
        field :name
        field :call_sign
        field :keeper
        field :notes
        field :web_site
        field :tx_frequency
        field :rx_frequency
        field :operational
        field :fm
        field :dstar
        field :fusion
        field :dmr
        field :nxdn
        field :p25
        field :tetra
      end

      group "FM" do
        field :fm_tone_burst
        field :fm_ctcss_tone
        field :fm_tone_squelch
      end

      group "D-Star" do
        field :dstar_port
      end

      group "DMR" do
        field :dmr_color_code
        field :dmr_network
      end

      group "Location" do
        field :latitude
        field :longitude
        field :address
        field :locality
        field :region
        field :post_code
        field :country
        field :grid_square
        field :utc_offset
      end

      group "Gocoding" do
        field :geocoded_at
        field :geocoded_address
        field :geocoded_locality
        field :geocoded_region
        field :geocoded_post_code
        field :geocoded_country
      end

      group "Source" do
        field :redistribution_limitations
        field :source
        field :external_id do
          label "External ID"
        end
      end

      group "Other" do
        field :tx_antenna
        field :tx_antenna_polarization
        field :tx_power
        field :rx_antenna
        field :rx_antenna_polarization
        field :altitude_agl
        field :altitude_asl
        field :bearing
        field :band
        field :channel
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
#  bearing                    :string
#  call_sign                  :string
#  channel                    :string
#  dmr                        :boolean
#  dmr_color_code             :integer
#  dmr_network                :string
#  dstar                      :boolean
#  dstar_port                 :string
#  fm                         :boolean
#  fm_bandwidth               :string
#  fm_ctcss_tone              :decimal(, )
#  fm_tone_burst              :boolean
#  fm_tone_squelch            :boolean
#  fusion                     :boolean
#  geocoded_address           :string
#  geocoded_at                :datetime
#  geocoded_by                :string
#  geocoded_locality          :string
#  geocoded_post_code         :string
#  geocoded_region            :string
#  grid_square                :string
#  keeper                     :string
#  locality                   :string
#  location                   :geography        point, 4326
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
