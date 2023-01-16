FactoryBot.define do
  sequence(:call_sign) { |n| number_to_call_sign(n) }

  factory :repeater do
    call_sign
    sequence(:name) { |n| "Repeater #{call_sign}".strip }
    keeper { generate(:call_sign) }
    band { Repeater::BAND_2M }

    tx_frequency { 144962500 } # VHF, maybe dispatch on the band for different frequencies?
    rx_frequency { tx_frequency - 600000 } # VHF, maybe dispatch on the band for different frequencies?
    access_method { Repeater::TONE_BURST }

    operational { true }

    latitude { 51.74 }
    longitude { -3.42 }
    country_id { "gb" }
    region_1 { "WM" }
    grid_square { "IO81HR" }

    after(:build) do |repeater|
      # If no mode was selected, select FM.
      if !(repeater.fm? || repeater.dstar? || repeater.fusion? || repeater.dmr? || repeater.nxdn?)
        repeater.fm = true
      end
    end
  end
end

# This method counts in call sign, so base 26 for 3 characters, then base 10 for a number, and then base 26 for another
# character. Sort of.
def number_to_call_sign(n)
  letters = ("A".."Z").to_a

  call_sign = StringIO.new
  call_sign << letters[n % 26]
  n /= 26
  call_sign << letters[n % 26]
  n /= 26
  call_sign << letters[n % 26]
  n /= 26
  call_sign << n % 10
  n /= 10
  call_sign << letters[n % 26]

  call_sign.string.reverse
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
#  location      :geography        point, 4326
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
#  index_repeaters_on_location    (location) USING gist
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
