FactoryBot.define do
  factory :country do
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
