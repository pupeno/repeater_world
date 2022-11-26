class RepeaterSearch < ApplicationRecord
end

# == Schema Information
#
# Table name: repeater_searches
#
#  id            :uuid             not null, primary key
#  band_10m      :boolean
#  band_23cm     :boolean
#  band_2m       :boolean
#  band_4m       :boolean
#  band_6m       :boolean
#  band_70cm     :boolean
#  coordinates   :boolean
#  distance      :integer
#  distance_unit :string
#  dmr           :boolean
#  dstar         :boolean
#  fm            :boolean
#  fusion        :boolean
#  geo           :boolean
#  latitude      :decimal(, )
#  longitude     :decimal(, )
#  nxdn          :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
