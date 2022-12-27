class RepeaterSearchesController < ApplicationController
  before_action :set_repeater_search, only: %i[show edit update destroy]
  before_action :authenticate_user!, except: %i[new]

  # TODO: implement
  # def index
  #   @repeater_searches = RepeaterSearch.all
  # end

  def new
    defaults = {distance: 8, distance_unit: RepeaterSearch::KM}
    @repeater_search = RepeaterSearch.new(defaults.merge(repeater_search_params))
    @repeaters = @repeater_search.run(page: params[:p] || 1) if !repeater_search_params.empty?
  end

  def create
    @repeater_search = RepeaterSearch.new(repeater_search_params)
    @repeater_search.user = current_user

    if @repeater_search.save
      redirect_to @repeater_search
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @repeaters = @repeater_search.run(page: params[:p] || 1)
  end

  def update
    if @repeater_search.update(repeater_search_params)
      redirect_to @repeater_search
    else
      render :show, status: :unprocessable_entity
    end
  end

  # TODO: implement
  # def destroy
  #   @repeater_search.destroy
  #   redirect_to repeater_searches_url, notice: "Repeater search was successfully destroyed."
  # end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_repeater_search
    @repeater_search = current_user.repeater_searches.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def repeater_search_params
    params.fetch(:s, {}).permit(
      Repeater::BANDS.map { |b| :"band_#{b}" } +
        Repeater::MODES +
        [:distance_to_coordinates, :distance, :distance_unit, :latitude, :longitude]
    )
  end
end
