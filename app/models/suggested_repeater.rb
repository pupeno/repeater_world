# Copyright 2023, Flexpoint Tech
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Foobar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with Foobar. If not, see
# <https://www.gnu.org/licenses/>.

class SuggestedRepeater < ApplicationRecord
  def to_s(extra = nil)
    super("#{name}:#{call_sign}")
  end
end

# == Schema Information
#
# Table name: suggested_repeaters
#
#  id                  :uuid             not null, primary key
#  access_method       :string
#  band                :string
#  call_sign           :string
#  channel             :string
#  country             :string
#  ctcss_tone          :string
#  dmr                 :boolean
#  dmr_color_code      :string
#  dmr_network         :string
#  dstar               :boolean
#  fm                  :boolean
#  fusion              :boolean
#  grid_square         :string
#  keeper              :string
#  latitude            :string
#  longitude           :string
#  name                :string
#  notes               :text
#  nxdn                :boolean
#  private_notes       :text
#  region_1            :string
#  region_2            :string
#  region_3            :string
#  region_4            :string
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
