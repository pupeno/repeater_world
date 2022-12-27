class RepeatersController < ApplicationController
  def show
    @repeater = Repeater.find(params[:id])
  end
end
