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

RSpec.describe Admin, type: :model do
  context "An admin" do
    before { @admin = create(:admin) }

    it "is readable" do
      expect(@admin.to_s).to include(@admin.class.name)
      expect(@admin.to_s).to include(@admin.id)
      expect(@admin.to_s).to include(@admin.email)
    end

    it "should remember me by default" do
      expect(@admin.remember_me).to eq("1") # HTML input values are strings, even when they are numbers
      @admin.remember_me = "0"
      expect(@admin.remember_me).to eq("0")
    end
  end
end
