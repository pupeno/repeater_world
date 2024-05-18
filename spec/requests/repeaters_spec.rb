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

RSpec.describe "/repeaters", type: :request do
  it "shows a repeater full of data" do
    repeater = create(:repeater, :full,
      name: "A Repeater",
      call_sign: "C4LLS1GN",
      tx_frequency: 144_962_500,
      rx_frequency: 144_362_500)
    get repeater_url(repeater)
    expect(response).to be_successful
    expect(response.body).to include("A Repeater")
    expect(response.body).to include("C4LLS1GN")
    expect(response.body).to include("144.9625MHz")
    expect(response.body).to include("144.3625MHz")
    expect(response.body).to include("-600kHz")
  end

  it "shows a repeater void of data" do
    repeater = create(:repeater)
    get repeater_url(repeater)
    expect(response).to be_successful # We are mostly checking for crashes due to assuming a value exists.
  end

  it "redirects from an old slug" do
    repeater = create(:repeater)
    old_url = repeater_url(repeater)
    repeater.call_sign = "nw4cs"
    repeater.slug = nil # TODO: remove this when we generate slugs on data change.
    repeater.save!
    expect(repeater_url(repeater)).not_to eq(old_url)
    get old_url
    expect(response).to redirect_to(repeater_url(repeater))
  end
end
