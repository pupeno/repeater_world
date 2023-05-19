# Copyright 2023, Pablo Fernandez
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

RSpec.describe "/repeaters", type: :request do
  it "shows a repeater" do
    repeater = create(:repeater, name: "A Repeater", call_sign: "123")
    get repeater_url(repeater)
    expect(response).to be_successful
    expect(response.body).to include("A Repeater")
    expect(response.body).to include("123")
  end
end
