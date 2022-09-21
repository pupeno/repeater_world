class Country < ApplicationRecord
  validates :code, presence: true, uniqueness: { case_sensitive: false }, inclusion: ISO3166::Country.codes.map(&:downcase)
  validates :name, presence: true

  def to_s(extra = nil)
    super(name)
  end

  def self.create_all
    ISO3166::Country.codes.each do |code|
      country = find_or_initialize_by(code: code.downcase)
      country.name = ISO3166::Country[code].common_name
      country.save!
    end
  end

  rails_admin do
    list do
      field :code
      field :name
    end
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
