FactoryBot.define do
  factory :repeater do
    
  end
end

# == Schema Information
#
# Table name: repeaters
#
#  id           :uuid             not null, primary key
#  band         :string
#  call_sign    :string
#  channel      :string
#  grid_square  :string
#  keeper       :string
#  latitude     :decimal(, )
#  longitude    :decimal(, )
#  name         :string
#  region_1     :string
#  region_2     :string
#  region_3     :string
#  region_4     :string
#  rx_frequency :decimal(, )
#  tx_frequency :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  country_id   :uuid
#
# Indexes
#
#  index_repeaters_on_country_id  (country_id)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
