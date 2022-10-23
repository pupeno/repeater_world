require 'rails_helper'

RSpec.describe Repeater, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: repeaters
#
#  id            :uuid             not null, primary key
#  access_method :string
#  band          :string
#  call_sign     :string
#  channel       :string
#  ctcss_tone    :decimal(, )
#  dmr           :boolean
#  dstar         :boolean
#  fm            :boolean
#  fusion        :boolean
#  grid_square   :string
#  keeper        :string
#  latitude      :decimal(, )
#  longitude     :decimal(, )
#  name          :string
#  nxdn          :boolean
#  region_1      :string
#  region_2      :string
#  region_3      :string
#  region_4      :string
#  rx_frequency  :decimal(, )
#  tone_sql      :boolean
#  tx_frequency  :decimal(, )
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  country_id    :string
#
# Indexes
#
#  index_repeaters_on_call_sign   (call_sign)
#  index_repeaters_on_country_id  (country_id)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
