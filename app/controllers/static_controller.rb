class StaticController < ApplicationController
  def fail
    raise "Bogus exception to test exception handler"
  end

  def fail_bg
    FailJob.perform_later
  end
end
