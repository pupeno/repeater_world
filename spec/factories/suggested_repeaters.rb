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

# == Schema Information
#
# Table name: suggested_repeaters
#
#  id                      :uuid             not null, primary key
#  address                 :string
#  altitude_agl            :string
#  altitude_asl            :string
#  band                    :string
#  bandwidth               :string
#  bearing                 :string
#  call_sign               :string
#  channel                 :string
#  dmr                     :boolean
#  dmr_color_code          :string
#  dmr_network             :string
#  done_at                 :datetime
#  dstar                   :boolean
#  dstar_port              :string
#  echo_link               :boolean
#  echo_link_node_number   :integer
#  fm                      :boolean
#  fm_ctcss_tone           :string
#  fm_tone_burst           :boolean
#  fm_tone_squelch         :boolean
#  fusion                  :boolean
#  grid_square             :string
#  keeper                  :string
#  latitude                :string
#  locality                :string
#  longitude               :string
#  name                    :string
#  notes                   :text
#  nxdn                    :boolean
#  p25                     :boolean
#  post_code               :string
#  private_notes           :text
#  region                  :string
#  rx_antenna              :string
#  rx_antenna_polarization :string
#  rx_frequency            :string
#  submitter_call_sign     :string
#  submitter_email         :string
#  submitter_keeper        :boolean
#  submitter_name          :string
#  submitter_notes         :text
#  tetra                   :boolean
#  tx_antenna              :string
#  tx_antenna_polarization :string
#  tx_frequency            :string
#  tx_power                :string
#  web_site                :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  country_id              :string
#  repeater_id             :uuid
#  wires_x_node_id         :string
#
# Indexes
#
#  index_suggested_repeaters_on_country_id   (country_id)
#  index_suggested_repeaters_on_repeater_id  (repeater_id)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (repeater_id => repeaters.id)
#
