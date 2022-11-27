source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.1"

gem "activerecord-postgis-adapter", "~> 8.0"
gem "babosa", "~> 2.0.0"
gem "bootsnap", require: false # Reduces boot times through caching; required in config/boot.rb
gem "countries", "~> 5.1"
gem "devise", "~> 4.8.1"
gem "devise-async", "~> 1.0.0"
gem "factory_bot_rails", "~> 6" # To be able to generate sample data in staging (which is production).
gem "faker", "~> 3.0" # To be able to generate sample data in staging (which is production).
gem "importmap-rails" # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "pg", "~> 1.1" # Use postgresql as the database for Active Record
gem "postmark-rails", "~> 0.22.0"
gem "puma", "~> 6.0" # Use the Puma web server [https://github.com/puma/puma]
gem "rails", "~> 7.0.2", ">= 7.0.2.2" # Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails_admin", "~> 3.1.0"
gem "sassc-rails", "~> 2.1.2" # Asked by rails_admin... but it's not a dependency??? the world is complicated.
gem "sentry-rails", "~> 5.3"
gem "sentry-ruby", "~> 5.3"
gem "sprockets-rails" # The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "stimulus-rails" # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "tailwindcss-rails" # Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "turbo-rails" # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
# gem "sidekiq", "~> 6.4" # Uncomment this when starting to use proper background jobs.
# # gem "sentry-sidekiq", "~> 5.3" # Uncomment this when starting to use proper background jobs.
# gem "bcrypt", "~> 3.1.7" # Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "image_processing", "~> 1.2" # Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "kredis" # Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "redis", "~> 4.0" # Use Redis adapter to run Action Cable in production
# gem "sassc-rails" # Use Sass to process CSS

group :development, :test do
  gem "capybara", "~> 3.37"
  gem "brakeman", "~> 5.3"
  gem "debug", platforms: %i[mri mingw x64_mingw] # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "rspec-rails", "~> 5.1" # TODO: figure out how to make ~> 6.0 work in RubyMine.
  gem "standard", "~> 1.12"
  gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
end

group :development do
  gem "annotate", "~> 3.2.0"
  gem "web-console" # Use console on exceptions pages [https://github.com/rails/web-console]
  # gem "rack-mini-profiler" # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "spring" # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
end

group :test do
  gem "simplecov", require: false
  gem "simplecov-cobertura"
end
