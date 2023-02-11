class RepeatersController < ApplicationController
  def show
    @repeater = Repeater.find(params[:id].split("-").take(5).join("-"))
  end
end
