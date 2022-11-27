class RepeaterSearchesController < ApplicationController
  before_action :set_repeater_search, only: %i[show edit update destroy]

  # TODO: implement
  # def index
  #   @repeater_searches = RepeaterSearch.all
  # end

  def new
    @repeater_search = RepeaterSearch.new(distance: 8, distance_unit: RepeaterSearch::KM)
  end

  def create
    @repeater_search = RepeaterSearch.new(repeater_search_params)

    if @repeater_search.save
      redirect_to @repeater_search
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @repeaters = Repeater

    bands = Repeater::BANDS.filter { |band| @repeater_search.send(:"band_#{band}?") }
    @repeaters = @repeaters.where(band: bands) if bands.present?

    modes = Repeater::MODES.filter { |mode| @repeater_search.send(:"#{mode}?") }
    if modes.present?
      cond = Repeater.where(modes.first => true)
      modes[1..]&.each do |mode|
        cond = cond.or(Repeater.where(mode => true))
      end
      @repeaters = @repeaters.merge(cond)
    end

    if @repeater_search.distance_to_coordinates?
      distance = @repeater_search.distance * ((@repeater_search.distance_unit == RepeaterSearch::MILES) ? 1609.34 : 1000)
      @repeaters = @repeaters.where(
        "ST_DWithin(location, :point, :distance)",
        {point: Geo.to_wkt(Geo.point(@repeater_search.latitude, @repeater_search.longitude)),
         distance: distance}
      ).all
    end

    @repeaters = @repeaters.all
  end

  # TODO: implement
  # def edit
  # end

  def update
    if @repeater_search.update(repeater_search_params)
      redirect_to @repeater_search
    else
      render :edit, status: :unprocessable_entity
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
    @repeater_search = RepeaterSearch.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def repeater_search_params
    params.fetch(:repeater_search, {}).permit(
      Repeater::BANDS.map { |b| :"band_#{b}" } +
        Repeater::MODES +
        [:distance_to_coordinates, :distance, :distance_unit, :latitude, :longitude]
    )
  end
end
