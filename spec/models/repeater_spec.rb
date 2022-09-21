require 'rails_helper'

RSpec.describe Repeater, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
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
#  rx_frequency :decimal(, )
#  tx_frequency :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
