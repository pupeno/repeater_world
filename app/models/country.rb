# Copyright 2023, Flexpoint Tech
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Foobar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
# <https://www.gnu.org/licenses/>.

class Country < ApplicationRecord
  validates :id, presence: true, uniqueness: {case_sensitive: false}, inclusion: ISO3166::Country.codes.map(&:downcase)
  validates :name, presence: true

  def to_s(extra = nil)
    super(name)
  end

  def self.create_all
    Rails.logger.info "Creating #{ISO3166::Country.codes.count} countries..."
    ISO3166::Country.codes.each do |code|
      country = find_or_initialize_by(id: code.downcase)
      country.name = ISO3166::Country[code].common_name
      country.save!
    end
    Rails.logger.info "Created #{ISO3166::Country.codes.count} countries."
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
