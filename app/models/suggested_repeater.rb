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

class SuggestedRepeater < ApplicationRecord
  belongs_to :country
  belongs_to :repeater, optional: true

  def to_s(extra = nil)
    super("#{name}:#{call_sign}")
  end

  rails_admin do
    list do
      field :country
      field :repeater
      field :name
      field :call_sign
      field :band
      field :tx_frequency
      field :submitter_name
      field :submitter_email
      field :submitter_call_sign
      field :done_at
      field :created_at
    end

    show do
      group "Submiter" do
        field :submitter_name
        field :submitter_email
        field :submitter_call_sign
        field :submitter_keeper
        field :submitter_notes
      end

      group "Essentials" do
        field :repeater
        field :name
        field :call_sign
        field :keeper
        field :notes
        field :web_site
        field :tx_frequency
        field :rx_frequency
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

      group "Location" do
        field :address
        field :locality
        field :region
        field :post_code
        field :country
        field :latitude
        field :longitude
        field :grid_square
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

      group "Internal" do
        field :private_notes
        field :done_at
      end

      group "Record" do
        field :id
        field :created_at
        field :updated_at
      end
    end

    edit do
      group "Submiter" do
        field :submitter_name
        field :submitter_email
        field :submitter_call_sign
        field :submitter_keeper
        field :submitter_notes
      end

      group "Essentials" do
        field :repeater
        field :name
        field :call_sign
        field :keeper
        field :notes
        field :web_site
        field :tx_frequency
        field :rx_frequency
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

      group "Location" do
        field :address
        field :locality
        field :region
        field :post_code
        field :country
        field :latitude
        field :longitude
        field :grid_square
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

      group "Internal" do
        field :private_notes
        field :done_at
      end
    end
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
#  m17                     :boolean
#  m17_can                 :integer
#  m17_reflector_name      :string
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
