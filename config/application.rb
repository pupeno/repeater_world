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

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RepeaterWorld
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # https://stackoverflow.com/questions/17951037/how-to-require-some-lib-files-from-anywhere
    config.autoload_paths += %W[#{config.root}/lib]
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Don't generate system test files.
    config.generators.system_tests = nil

    # https://guides.rubyonrails.org/action_mailer_basics.html#previewing-emails
    config.action_mailer.preview_paths << "#{Rails.root}/spec/mailers/previews/"

    # Necessary for handling 404 errors, so that /404 gets called as a catch-all
    config.exceptions_app = routes

    # https://lab.io/articles/2017/04/13/uuids-rails-5-1/
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
  end
end
