require "rails_helper"

RSpec.describe RepeaterSearch, type: :model do
  it "should always validate distance_to_coordinate fields" do
    repeater_search = create(:repeater_search, distance_to_coordinates: false)
    expect(repeater_search).to be_valid

    repeater_search.distance = "hello" # this is always invalid, no matter the state of distance_to_cordinates
    expect(repeater_search).to_not be_valid

    repeater_search.distance = nil # this is valid when distance_to_coordinates is false...
    expect(repeater_search).to be_valid

    repeater_search.distance_to_coordinates = true # ...but not when it's true.
    expect(repeater_search).to_not be_valid
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
#  user_id                 :uuid
#
# Indexes
#
#  index_repeater_searches_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
