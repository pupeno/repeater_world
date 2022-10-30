class Repeater < ApplicationRecord
  BANDS = [
    BAND_10M = "10m",
    BAND_6M = "6m",
    BAND_4M = "4m",
    BAND_2M = "2m",
    BAND_70CM = "70cm",
    BAND_23CM = "23cm"
  ]

  ACCESS_METHODS = [
    TONE_BURST = "tone_burst",
    CTCSS = "ctcss"
  ]

  CTCSS_CODES = [
    67.0, 69.3, 71.9, 74.4, 77.0, 79.7, 82.5, 85.4, 88.5, 91.5, 94.8, 97.4, 100.0, 103.5, 107.2, 110.9, 114.8, 118.8,
    123, 127.3, 131.8, 136.5, 141.3, 146.2, 151.4, 156.7, 162.2, 167.9, 173.8, 179.9, 186.2, 192.8, 203.5, 210.7, 218.1,
    225.7, 233.6, 241.8, 250.3
  ]

  belongs_to :country

  validates :name, presence: true
  validates :band, presence: true, inclusion: BANDS
  validates :tx_frequency, presence: true # TODO: validate the frequency is within the band.
  validates :rx_frequency, presence: true # TODO: validate the frequency is within the band.
  validates :access_method, inclusion: ACCESS_METHODS, allow_blank: true
  validates :ctcss_tone,
    presence: {if: lambda { |r| r.access_method == CTCSS }},
    inclusion: {in: CTCSS_CODES, if: lambda { |r| r.access_method == CTCSS }}

  def to_s(extra = nil)
    super("#{name}:#{call_sign}")
  end
end

# == Schema Information
#
# Table name: repeaters
#
#  id            :uuid             not null, primary key
#  access_method :string
#  band          :string
#  call_sign     :string
#  channel       :string
#  ctcss_tone    :decimal(, )
#  dmr           :boolean
#  dmr_cc        :integer
#  dmr_con       :string
#  dstar         :boolean
#  fm            :boolean
#  fusion        :boolean
#  grid_square   :string
#  keeper        :string
#  latitude      :decimal(, )
#  longitude     :decimal(, )
#  name          :string
#  notes         :text
#  nxdn          :boolean
#  operational   :boolean
#  region_1      :string
#  region_2      :string
#  region_3      :string
#  region_4      :string
#  rx_frequency  :decimal(, )
#  source        :string
#  tone_sql      :boolean
#  tx_frequency  :decimal(, )
#  utc_offset    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  country_id    :string
#
# Indexes
#
#  index_repeaters_on_call_sign   (call_sign)
#  index_repeaters_on_country_id  (country_id)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
