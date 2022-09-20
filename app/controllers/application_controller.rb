class ApplicationController < ActionController::Base
  unless Rails.application.config.consider_all_requests_local
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
  end

  def not_found
    render "static/not_found", status: :not_found
  end
end
