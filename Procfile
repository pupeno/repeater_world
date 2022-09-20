web: bundle exec puma --threads 5:5 --port ${PORT:-3000} --environment ${RACK_ENV:-development}
worker: bundle exec sidekiq
release: rake db:migrate
