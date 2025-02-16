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
    fm_tone_squelch { "fm_tone_squelch" }

    m17 { true }
    m17_can { 5 }
    m17_reflector_name { "reflector name" }

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
    country_id { "gb" }

    private_notes { "private notes" }
  end
end
