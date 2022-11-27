FactoryBot.define do
  factory :repeater_search do
  end
end

# == Schema Information
#
# Table name: repeater_searches
#
#  id                      :uuid             not null, primary key
#  band_10m                :boolean
#  band_23cm               :boolean
#  band_2m                 :boolean
#  band_4m                 :boolean
#  band_6m                 :boolean
#  band_70cm               :boolean
#  distance                :integer
#  distance_to_coordinates :boolean
#  distance_unit           :string
#  dmr                     :boolean
#  dstar                   :boolean
#  fm                      :boolean
#  fusion                  :boolean
#  latitude                :decimal(, )
#  longitude               :decimal(, )
#  nxdn                    :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
