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

FactoryBot.define do
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
    address { "address" }
    locality { "city" }
    region { "region" }
    post_code { "PC" }
    country_id { "gb" }
    grid_square { "IO81HR" }

    after(:build) do |repeater|
      # If no mode was selected, select FM.
      if !(repeater.fm? || repeater.dstar? || repeater.fusion? || repeater.dmr? || repeater.nxdn?)
        repeater.fm = true
      end
    end
  end
end

# == Schema Information
#
# Table name: repeaters
#
#  id                         :uuid             not null, primary key
#  access_method              :string
#  address                    :string
#  band                       :string
#  call_sign                  :string
#  channel                    :string
#  ctcss_tone                 :decimal(, )
#  dmr                        :boolean
#  dmr_color_code             :integer
#  dmr_network                :string
#  dstar                      :boolean
#  fm                         :boolean
#  fusion                     :boolean
#  grid_square                :string
#  keeper                     :string
#  locality                   :string
#  location                   :geography        point, 4326
#  name                       :string
#  notes                      :text
#  nxdn                       :boolean
#  operational                :boolean
#  post_code                  :string
#  redistribution_limitations :string
#  region                     :string
#  rx_frequency               :decimal(, )
#  source                     :string
#  tone_sql                   :boolean
#  tx_frequency               :decimal(, )
#  utc_offset                 :string
#  web_site                   :string
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
