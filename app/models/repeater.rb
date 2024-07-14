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
    M17 = "m17",
    DSTAR = "dstar",
    FUSION = "fusion",
    DMR = "dmr",
    NXDN = "nxdn",
    P25 = "p25",
    TETRA = "tetra"
  ]

  MODE_NAMES = {
    FM => "FM",
    M17 => "M17",
    DSTAR => "D-Star",
    FUSION => "Fusion",
    DMR => "DMR",
    NXDN => "NXDN",
    P25 => "P25",
    TETRA => "TETRA"
  }

  CTCSS_TONES = [
    67.0, 69.3, 71.9, 74.4, 77.0, 79.7, 82.5, 85.4, 88.5, 91.5, 94.8, 97.4, 100.0, 103.5, 107.2, 110.9, 114.8, 118.8,
    123, 127.3, 131.8, 136.5, 141.3, 146.2, 151.4, 156.7, 162.2, 167.9, 173.8, 179.9, 186.2, 192.8, 203.5, 210.7, 218.1,
    225.7, 233.6, 241.8, 250.3
  ]

  M17_CANS = (0..15).to_a

  DMR_COLOR_CODES = (0..15).to_a

  BANDWIDTHS = [
    FM_WIDE = 25_000,
    FM_NARROW = 12_500
  ]

  belongs_to :country, optional: true
  belongs_to :input_country, class_name: "Country", optional: true
  belongs_to :geocoded_country, class_name: "Country", optional: true
  has_many :suggested_repeaters, dependent: :nullify

  validates :call_sign, presence: true
  validates :band, presence: true, inclusion: BANDS
  validates :tx_frequency, presence: true # TODO: validate the frequency is within the band: https://github.com/pupeno/repeater_world/issues/20
  validates :rx_frequency, presence: true # TODO: validate the frequency is within the band: https://github.com/pupeno/repeater_world/issues/20
  validates :fm_ctcss_tone, inclusion: CTCSS_TONES, allow_blank: true
  validates :m17_can, inclusion: M17_CANS, allow_blank: true
  validates :dmr_color_code, inclusion: DMR_COLOR_CODES, allow_blank: true

  before_validation :ensure_fields_are_set
  before_validation :compute_location_fields

  include PgSearch::Model
  multisearchable(
    against: [
      :address, :band, :call_sign, :channel, :dmr_network, :dmr_color_code, :dstar_port,
      :fm_ctcss_tone, :grid_square, :keeper, :locality, :name, :notes, :post_code, :region,
      :rx_antenna, :rx_antenna_polarization, :rx_frequency, :source, :tx_antenna,
      :tx_antenna_polarization, :tx_frequency, :web_site, :country_name, :m17_can, :m17_reflector_name
    ],
    additional_attributes: ->(repeater) { {repeater_id: repeater.id} }
  )
  delegate :name, to: :country, prefix: true, allow_nil: true
  delegate :name, to: :input_country, prefix: true, allow_nil: true

  include FriendlyId
  if Rails.env.test? # Unfortunately, slug generation becomes very slow in tests: https://stackoverflow.com/questions/78505982/is-there-a-way-to-turn-of-friendly-id-or-at-least-the-history-module-during-test
    friendly_id :generate_friendly_id, use: [:slugged]
  else
    friendly_id :generate_friendly_id, use: [:slugged, :history]
  end

  def to_s(extra = nil)
    super("#{name}:#{call_sign}")
  end

  def name
    super || [locality, call_sign].compact.join(" ")
  end

  def input_latitude
    input_coordinates&.latitude
  end

  def input_latitude=(value)
    @input_latitude = value
    set_input_coordinates_if_not_nil
  end

  def input_longitude
    input_coordinates&.longitude
  end

  def input_longitude=(value)
    @input_longitude = value
    set_input_coordinates_if_not_nil
  end

  def latitude
    coordinates&.latitude
  end

  def latitude=(value)
    @latitude = value
    set_coordinates_if_not_nil
  end

  def longitude
    coordinates&.longitude
  end

  def longitude=(value)
    @longitude = value
    set_coordinates_if_not_nil
  end

  def disable_all_modes
    MODES.each { |mode| send(:"#{mode}=", nil) }
  end

  def generate_friendly_id
    s = [:call_sign, :name, :band,
      -> { RepeaterUtils.mode_names(self).join("-") },
      -> { RepeaterUtils.location_in_words(self) }]
    [s, s + [:id]]
  end

  def web_site=(value)
    if value.present? && !value.start_with?("http://") && !value.start_with?("https://")
      value = "http://#{value}"
    end
    super
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
    if bandwidth.blank?
      self.bandwidth = FM_WIDE
    end
  end

  def should_generate_new_friendly_id?
    if slug.blank?
      return true
    end
    if Rails.env.test? # Unfortunately, slug generation becomes very slow in tests: https://stackoverflow.com/questions/78505982/is-there-a-way-to-turn-of-friendly-id-or-at-least-the-history-module-during-test
      false
    else
      predicates = [slug.blank?, call_sign_changed?, name_changed?, band_changed?]
      predicates += MODES.map { |m| send(:"#{m}_changed?") }
      predicates += [address_changed?, locality_changed?, region_changed?, post_code_changed?, country_id_changed?]
      predicates.any?
    end
  end

  def compute_location_fields
    # If blank, set to null, which is a better blank value.
    self.input_address = nil if input_address.blank?
    self.input_locality = nil if input_locality.blank?
    self.input_region = nil if input_region.blank?
    self.input_post_code = nil if input_post_code.blank?
    self.input_country_id = nil if input_country_id.blank?
    self.input_coordinates = nil if input_coordinates.blank?
    self.input_grid_square = nil if input_grid_square.blank?

    # Coordinates are expensive to calculate, since they require a geocoding call, so we need some special logic.
    # If there are input ones, we use them as is. If not, we only blank location if the address change in any way.
    if input_coordinates.present?
      self.coordinates = input_coordinates
      self.geocoded_at = nil
      self.geocoded_by = nil
    elsif input_address != address ||
        input_locality != locality ||
        input_region != region ||
        input_post_code != post_code ||
        input_country_id != country_id ||
        (geocoded_at.present? && geocoded_at <= 1.year.ago)
      self.coordinates = nil
      self.geocoded_at = nil
      self.geocoded_by = nil
    end

    # First, all other input values are used as-is.
    self.address = input_address
    self.locality = input_locality
    self.region = input_region
    self.post_code = input_post_code
    self.country_id = input_country_id
    self.geocoded_country_id = input_country_id # Only temporarily, will be removed later.
    self.grid_square = input_grid_square

    # Let's try to fill in some blanks now

    # If we have an address but no coordinates, let's geocode.
    if coordinates.blank? && [address, locality, region, post_code, country_id].any?(&:present?)
      geocode
    end

    # If we have coordinates but no grid square, let's calculate it.
    if grid_square.blank? && coordinates.present?
      self.grid_square = DX::Grid.encode([latitude, longitude], length: 6)
    end

    # if we have grid square, but no coordinates, lets calculate them.
    # If we have coordinates but no grid square, let's calculate it.
    if coordinates.blank? && grid_square.present?
      latitude, longitude = DX::Grid.decode(grid_square)
      self.coordinates = Geo.point(latitude, longitude)
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
        field :m17
        field :dstar
        field :fusion
        field :dmr
        field :nxdn
        field :p25
        field :tetra
        field :echo_link
      end

      group "FM" do
        field :fm_tone_burst
        field :fm_ctcss_tone
        field :fm_tone_squelch
      end

      group "M17" do
        field :m17_can
        field :m17_reflector_name
      end

      group "D-Star" do
        field :dstar_port
      end

      group "Fusion" do
        field :wires_x_node_id
      end

      group "DMR" do
        field :dmr_color_code
        field :dmr_network
      end

      group "EchoLink" do
        field :echo_link
        field :echo_link_node_number
      end

      group "Input Location" do
        field :input_address
        field :input_locality
        field :input_region
        field :input_post_code
        field :input_country
        field :input_latitude
        field :input_longitude
        field :input_grid_square
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
        field :bandwidth
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
        field :slug
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
        field :m17
        field :dstar
        field :fusion
        field :dmr
        field :nxdn
        field :p25
        field :tetra
        field :echo_link
      end

      group "FM" do
        field :fm_tone_burst
        field :fm_ctcss_tone
        field :fm_tone_squelch
      end

      group "M17" do
        field :m17_can
        field :m17_reflector_name
      end

      group "D-Star" do
        field :dstar_port
      end

      group "Fusion" do
        field :wires_x_node_id
      end

      group "DMR" do
        field :dmr_color_code
        field :dmr_network
      end

      group "EchoLink" do
        field :echo_link_node_number
      end

      group "Input Location" do
        field :input_address
        field :input_locality
        field :input_region
        field :input_post_code
        field :input_country
        field :input_latitude
        field :input_longitude
        field :input_grid_square
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
        field :bandwidth
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
        field :slug
      end
    end
  end

  private

  def geocode
    geocode = Geocoder.search(RepeaterUtils.location_in_words(self)).first
    self.coordinates = if geocode.present?
      Geo.point(geocode.latitude, geocode.longitude)
    end
    self.geocoded_at = Time.now
    self.geocoded_by = geocode.class.name
  end

  def set_input_coordinates_if_not_nil
    self.input_coordinates = if @input_latitude.present? && @input_longitude.present? # Only create a point when both parts are present.
      Geo.point(@input_latitude, @input_longitude)
    end
  end

  def set_coordinates_if_not_nil
    self.coordinates = if @latitude.present? && @longitude.present? # Only create a point when both parts are present.
      Geo.point(@latitude, @longitude)
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
