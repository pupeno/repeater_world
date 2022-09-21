FactoryBot.define do
  factory :country do
    
  end
end

# == Schema Information
#
# Table name: countries
#
#  id         :uuid             not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#  index_countries_on_name  (name) UNIQUE
#
