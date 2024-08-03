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

desc "Generate full sample data for development, staging, review apps."
task generate_sample_data: :environment do
  Rails.logger = Logger.new($stdout)
  Rake::Task["db:seed"].execute
  SampleDataGenerator.new.generate
end

desc "Generate sample users for development, staging, review apps."
task generate_sample_users: :environment do
  Rails.logger = Logger.new($stdout)
  Rake::Task["db:seed"].execute
  SampleDataGenerator.new.generate(mode: :users_only)
end
