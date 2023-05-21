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
  factory :suggested_repeater do
    submitter_name { Faker::Name.name }
    submitter_email { Faker::Internet.email }
    submitter_call_sign { "AA1AAA" }
    submitter_keeper { false }
    submitter_notes { "Submitter notes" }

    name { "name" }
    call_sign { "call sign" }
    band { "band" }
    channel { "channel " }
    keeper { "keeper" }
    notes { "notes" }
    web_site { "https://website" }

    tx_frequency { "tx freq" }
    rx_frequency { "rx freq" }

    fm { true }
    fm_tone_burst { true }
    fm_ctcss_tone { "ctcss_tone" }
    tone_sql { "tone_sql" }

    dstar { true }

    fusion { true }

    dmr { true }
    dmr_color_code { "dmr color code" }
    dmr_network { "dmr network" }

    nxdn { "nxdn" }

    latitude { "latitude" }
    longitude { "longitude" }
    grid_square { "grid square" }
    address { "address" }
    locality { "locality" }
    region { "region" }
    post_code { "post code" }
    country { "country" }

    private_notes { "private notes" }
  end
end

# == Schema Information
#
# Table name: suggested_repeaters
#
#  id                  :uuid             not null, primary key
#  address             :string
#  band                :string
#  call_sign           :string
#  channel             :string
#  country             :string
#  dmr                 :boolean
#  dmr_color_code      :string
#  dmr_network         :string
#  dstar               :boolean
#  fm                  :boolean
#  fm_ctcss_tone       :string
#  fm_tone_burst       :boolean
#  fusion              :boolean
#  grid_square         :string
#  keeper              :string
#  latitude            :string
#  locality            :string
#  longitude           :string
#  name                :string
#  notes               :text
#  nxdn                :boolean
#  post_code           :string
#  private_notes       :text
#  region              :string
#  rx_frequency        :string
#  submitter_call_sign :string
#  submitter_email     :string
#  submitter_keeper    :boolean
#  submitter_name      :string
#  submitter_notes     :text
#  tone_sql            :boolean
#  tx_frequency        :string
#  web_site            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
