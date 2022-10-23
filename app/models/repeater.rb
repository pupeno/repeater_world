class Repeater < ApplicationRecord
  validates :name, presence: true
  validates :band, presence: true, inclusion: %w{10m 6m 2m 70cm 23cm}
  # TODO: validate the frequency is within the band.

  def to_s(extra = nil)
    super("#{name}:#{call_sign}")
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
#  country_id   :string
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
