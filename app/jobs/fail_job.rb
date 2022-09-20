class FailJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false if respond_to? :sidekiq_options

  def perform
    raise "Bogus background job exception to test exception tracking"
  end
end
