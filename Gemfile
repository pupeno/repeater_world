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

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.3"

gem "net-pop", github: "ruby/net-pop" # Remove once bug is fixed upstream: https://stackoverflow.com/questions/78617432/strange-bundle-update-issue-disappearing-net-pop-0-1-2-dependency

gem "active_link_to", "~> 1.0"
gem "activerecord-postgis-adapter", "~> 9.0"
gem "babosa", "~> 2.0"
gem "bootsnap", "~> 1.18", require: false # Reduces boot times through caching; required in config/boot.rb
gem "countries", "~> 6.0"
gem "devise", "~> 4.9"
gem "devise-async", "~> 1.0"
gem "dotenv-rails", "~> 3.1"
gem "dx-grid", "~> 1.0"
gem "factory_bot_rails", "~> 6.4" # To be able to generate sample data in staging (which is production).
gem "faker", "~> 3.4" # To be able to generate sample data in staging (which is production).
gem "friendly_id", "~> 5.5"
gem "geocoder", "~> 1.8"
gem "importmap-rails", "~> 2.0" # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "jbuilder", "~> 2.11"
gem "kaminari", "~> 1.2"
gem "mailgun-ruby", "~>1.2"
gem "paper_trail", "~> 15.1"
gem "paper_trail-globalid", "~> 0.2"
gem "pg", "~> 1.5" # Use postgresql as the database for Active Record
gem "pg_search", "~> 2.3"
gem "puma", "~> 6.4" # Use the Puma web server [https://github.com/puma/puma]
gem "pundit", "~> 2.3"
gem "rails", "~> 7.1" # Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails_admin", "~> 3.1"
gem "rbzip2", "~> 0.3"
gem "sassc-rails", "~> 2.1" # Asked by rails_admin... but it's not a dependency??? the world is complicated.
gem "sentry-rails", "~> 5.18"
gem "sentry-ruby", "~> 5.19"
gem "sprockets-rails", "~> 3.5" # The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "stimulus-rails", "~> 1.3" # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "tailwindcss-rails", "~> 2.7" # Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "turbo-rails", "~> 1.4" # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
# gem "bcrypt", "~> 3.1.7" # Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "image_processing", "~> 1.2" # Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "kredis" # Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "redis", "~> 4.0" # Use Redis adapter to run Action Cable in production
# gem "sassc-rails" # Use Sass to process CSS
# gem "sentry-sidekiq", "~> 5.3" # Uncomment this when starting to use proper background jobs.
# gem "sidekiq", "~> 6.4" # Uncomment this when starting to use proper background jobs.

group :development, :test do
  gem "capybara", "~> 3.40"
  gem "brakeman", "~> 6.1"
  gem "debug", "~> 1.9", platforms: %i[mri mingw x64_mingw] # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "rspec-rails", "~> 6.1"
  gem "standard", "~> 1.39"
  gem "tzinfo-data", "~> 1.2022", platforms: %i[mingw mswin x64_mingw jruby] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
end

group :development do
  gem "annotate", "~> 3.2"
  gem "web-console", "~> 4.2" # Use console on exceptions pages [https://github.com/rails/web-console]
  # gem "rack-mini-profiler" # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "spring" # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
end

group :test do
  gem "rails-controller-testing", "~> 1.0"
  gem "simplecov", "~> 0.22", require: false
  gem "simplecov-cobertura", "~> 2.1"
end
