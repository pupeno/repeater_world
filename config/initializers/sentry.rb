if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]

    # https://docs.sentry.io/platforms/ruby/configuration/options/
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.traces_sample_rate = 0.1 # Lower this the more popular the app gets

    # https://docs.sentry.io/platforms/ruby/configuration/releases/
    if ENV["HEROKU_APP_NAME"].present?
      # https://devcenter.heroku.com/articles/dyno-metadata
      config.release = "unbreach@#{ENV["HEROKU_APP_NAME"]}@#{ENV["HEROKU_RELEASE_VERSION"]}"
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
