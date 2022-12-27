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
