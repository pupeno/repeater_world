require "rails_helper"

RSpec.describe Repeater, type: :model do
  context "A repeater" do
    before { @repeater = create(:repeater) }

    it "is readable" do
      expect(@repeater.to_s).to include(@repeater.class.name)
      expect(@repeater.to_s).to include(@repeater.id)
      expect(@repeater.to_s).to include(@repeater.name)
      expect(@repeater.to_s).to include(@repeater.call_sign)
    end
  end
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
#  dmr_cc        :integer
#  dmr_con       :string
#  dstar         :boolean
#  fm            :boolean
#  fusion        :boolean
#  grid_square   :string
#  keeper        :string
#  latitude      :decimal(, )
#  longitude     :decimal(, )
#  name          :string
#  notes         :text
#  nxdn          :boolean
#  operational   :boolean
#  region_1      :string
#  region_2      :string
#  region_3      :string
#  region_4      :string
#  rx_frequency  :decimal(, )
#  source        :string
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
