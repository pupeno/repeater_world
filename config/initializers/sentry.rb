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

if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]

    # https://docs.sentry.io/platforms/ruby/configuration/options/
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.traces_sample_rate = 0.1 # Lower this the more popular the app gets

    # https://docs.sentry.io/platforms/ruby/configuration/releases/
    if ENV["HEROKU_APP_NAME"].present?
      # https://devcenter.heroku.com/articles/dyno-metadata
      config.release = "repeater_world@#{ENV["HEROKU_APP_NAME"]}@#{ENV["HEROKU_RELEASE_VERSION"]}"
      config.environment = ENV["HEROKU_APP_NAME"].split("-").last
    elsif ENV["RENDER"] === "true"
      # https://render.com/docs/environment-variables
      if ENV["IS_PULL_REQUEST"] == "true"
        config.environment = "review"
      end
    end
  end

  # https://render.com/docs/environment-variables
  if ENV["IS_PULL_REQUEST"] == "true"
    Sentry.configure_scope do |scope|
      scope.set_tags(pr: ENV["RENDER_SERVICE_NAME"].split("-")[-1]) if ENV["RENDER_SERVICE_NAME"].present?
    end
  end
elsif Rails.env.production?
  raise "Missing SENTRY_DSN environment variable"
end
