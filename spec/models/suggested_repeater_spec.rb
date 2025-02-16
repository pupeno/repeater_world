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

require "rails_helper"

RSpec.describe SuggestedRepeater, type: :model do
  context "A suggested repeater" do
    before { @suggested_repeater = create(:suggested_repeater) }

    it "is readable" do
      expect(@suggested_repeater.to_s).to include(@suggested_repeater.class.name)
      expect(@suggested_repeater.to_s).to include(@suggested_repeater.id)
      expect(@suggested_repeater.to_s).to include(@suggested_repeater.name)
      expect(@suggested_repeater.to_s).to include(@suggested_repeater.call_sign)
    end
  end

  it "doesn't enforce uniqueness" do
    attributes = attributes_for(:suggested_repeater)
    expect do
      SuggestedRepeater.create!(attributes)
      SuggestedRepeater.create!(attributes) # will crash if it can't save.
    end.to change { SuggestedRepeater.count }.by(2)
  end
end
