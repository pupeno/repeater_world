require "rails_helper"

RSpec.describe Country, type: :model do
  it "create all" do
    Country.create_all
    country = Country.first
    expect(country.to_s).to include(country.id)
  end
end

# == Schema Information
#
# Table name: countries
#
#  id         :string           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_countries_on_name  (name) UNIQUE
#
