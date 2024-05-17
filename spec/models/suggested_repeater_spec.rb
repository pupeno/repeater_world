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

require "rails_helper"

RSpec.describe SuggestedRepeater, type: :model do
  context "A suggested repeater" do
    before { @suggested_repeater = create(:suggested_repeater) }

    it "is readable" do
      expect(@suggested_repeater.to_s).to include(@suggested_repeater.class.name)
      expect(@suggested_repeater.to_s).to include(@suggested_repeater.id)
      expect(@suggested_repeater.to_s).to include(@suggested_repeater.name)
      expect(@suggested_repeater.to_s).to include(@suggested_repeater.call_sign)
    end
  end

  it "doesn't enforce uniqueness" do
    attributes = attributes_for(:suggested_repeater)
    expect do
      SuggestedRepeater.create!(attributes)
      SuggestedRepeater.create!(attributes) # will crash if it can't save.
    end.to change { SuggestedRepeater.count }.by(2)
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
