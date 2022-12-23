require "rails_helper"

RSpec.describe Repeater, type: :model do
  it "has latitude and longitude" do
    @repeater = build(:repeater)
    @repeater.location = nil
    expect(@repeater.latitude).to be(nil)
    expect(@repeater.longitude).to be(nil)
    @repeater.save!
    @repeater.reload
    expect(@repeater.latitude).to be(nil)
    expect(@repeater.longitude).to be(nil)

    @repeater.latitude = 1
    expect(@repeater.latitude).to eq(1)
    expect(@repeater.longitude).to eq(0)

    @repeater.longitude = 2
    expect(@repeater.latitude).to eq(1)
    expect(@repeater.longitude).to eq(2)
    @repeater.save
    @repeater.reload
    expect(@repeater.latitude).to eq(1)
    expect(@repeater.longitude).to eq(2)
  end

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
#  location      :geography        point, 4326
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
#  utc_offset    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  country_id    :string
#
# Indexes
#
#  index_repeaters_on_call_sign   (call_sign)
#  index_repeaters_on_country_id  (country_id)
#  index_repeaters_on_location    (location) USING gist
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
