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
  factory :repeater_search do
    association(:user)
    sequence(:name) { |n| "Repeater Search #{n}" }
  end
end

# == Schema Information
#
# Table name: repeater_searches
#
#  id             :uuid             not null, primary key
#  band_10m       :boolean          default(FALSE), not null
#  band_13cm      :boolean          default(FALSE), not null
#  band_1_25m     :boolean          default(FALSE), not null
#  band_23cm      :boolean          default(FALSE), not null
#  band_2m        :boolean          default(FALSE), not null
#  band_33cm      :boolean          default(FALSE), not null
#  band_3cm       :boolean          default(FALSE), not null
#  band_4m        :boolean          default(FALSE), not null
#  band_6cm       :boolean          default(FALSE), not null
#  band_6m        :boolean          default(FALSE), not null
#  band_70cm      :boolean          default(FALSE), not null
#  band_9cm       :boolean          default(FALSE), not null
#  distance       :integer
#  distance_unit  :string
#  dmr            :boolean          default(FALSE), not null
#  dstar          :boolean          default(FALSE), not null
#  fm             :boolean          default(FALSE), not null
#  fusion         :boolean          default(FALSE), not null
#  geosearch_type :string
#  grid_square    :string
#  latitude       :decimal(, )
#  longitude      :decimal(, )
#  name           :string
#  nxdn           :boolean          default(FALSE), not null
#  p25            :boolean          default(FALSE), not null
#  place          :string
#  search_terms   :string
#  tetra          :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  country_id     :string
#  user_id        :uuid
#
# Indexes
#
#  index_repeater_searches_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
