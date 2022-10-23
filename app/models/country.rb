class Country < ApplicationRecord
  validates :id, presence: true, uniqueness: { case_sensitive: false }, inclusion: ISO3166::Country.codes.map(&:downcase)
  validates :name, presence: true

  def to_s(extra = nil)
    super(name)
  end

  def self.create_all
    ISO3166::Country.codes.each do |code|
      country = find_or_initialize_by(id: code.downcase)
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
#  id         :string           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_countries_on_name  (name) UNIQUE
#
