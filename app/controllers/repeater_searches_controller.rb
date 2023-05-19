# Copyright 2023, Flexpoint Tech
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Foobar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with Foobar. If not, see
# <https://www.gnu.org/licenses/>.

class RepeaterSearchesController < ApplicationController
  before_action :authenticate_user!, except: %i[new export]
  before_action :set_repeater_search, only: %i[show edit update destroy]
  before_action :set_selected_tab_and_tab_urls, only: %i[new show create update]

  def index
    @repeater_searches = current_user.repeater_searches.page(params[:p] || 1)
  end

  def new
    defaults = {distance: 8, distance_unit: RepeaterSearch::KM}
    @repeater_search = RepeaterSearch.new(defaults.merge(repeater_search_params[:s] || {}))
    if repeater_search_params[:s].present?
      @repeaters = @repeater_search.run
      @repeaters = @repeaters.page(params[:p] || 1) if @selected_tab != "map"
    end

    if params[:export]
      @export_url = export_url(repeater_search_params)
    end

    modes = []
    modes << "FM" if @repeater_search.fm?
    modes << "D-Star" if @repeater_search.dstar?
    modes << "Fusion" if @repeater_search.fusion?
    modes << "DMR" if @repeater_search.dmr?
    modes << "NXDN" if @repeater_search.nxdn?
    modes << "All modes" if modes.empty?
    bands = []
    bands << "10m" if @repeater_search.band_10m?
    bands << "6m" if @repeater_search.band_6m?
    bands << "4m" if @repeater_search.band_4m?
    bands << "2m" if @repeater_search.band_2m?
    bands << "70cm" if @repeater_search.band_70cm?
    bands << "23cm" if @repeater_search.band_23cm?
    bands << "all bands" if bands.empty?
    distance = "#{@repeater_search.distance}#{@repeater_search.distance_unit} of #{@repeater_search.latitude}, #{@repeater_search.longitude}" if @repeater_search.distance_to_coordinates
    @repeater_search.name = "#{modes.to_sentence} on #{bands.to_sentence} #{distance}".strip
  end

  def export
    if params[:id].present?
      @repeater_search = RepeaterSearch.new(repeater_search_params[:s])
    else
      defaults = {distance: 8, distance_unit: RepeaterSearch::KM}
      @repeater_search = RepeaterSearch.new(defaults.merge(repeater_search_params[:s]))
    end
    exporter_class = Exporters::EXPORTER_FOR[repeater_search_params[:e][:format].to_sym]
    @export = exporter_class.new(@repeater_search.run).export
    send_data(@export, filename: "export.csv", disposition: "attachment")
  end

  def create
    @repeater_search = RepeaterSearch.new(repeater_search_params[:s])
    @repeater_search.user = current_user

    if @repeater_search.save
      redirect_to @repeater_search, notice: "You search is now saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    if repeater_search_params[:s].present?
      @repeater_search.assign_attributes(repeater_search_params[:s])
    end
    @repeaters = @repeater_search.run
    @repeaters = @repeaters.page(params[:p] || 1) if @selected_tab != "map"
    if params[:export]
      @export_url = export_repeater_search_url(@repeater_search, e: repeater_search_params[:e])
    end
  end

  def update
    if @repeater_search.update(repeater_search_params[:s])
      if params[:export]
        # redirect_to export_url(repeater_search_params)
        redirect_to repeater_search_url(@repeater_search, export: true, e: repeater_search_params[:e])
      else
        redirect_to @repeater_search, notice: "Your search is now saved."
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    name = @repeater_search.name
    @repeater_search.destroy
    redirect_to repeater_searches_url, notice: "The repeater search \"#{name}\" was deleted."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_repeater_search
    @repeater_search = current_user.repeater_searches.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def repeater_search_params
    params.permit(
      :d,
      s: Repeater::BANDS.map { |b| :"band_#{b}" } +
        Repeater::MODES +
        [:name, :distance_to_coordinates, :distance, :distance_unit, :latitude, :longitude],
      e: [:format]
    )
  end

  def set_selected_tab_and_tab_urls
    @selected_tab = params[:d] || "cards" # the default selected tab is "cards"
    @cards_url = search_url(repeater_search_params.merge(d: "cards"))
    @map_url = search_url(repeater_search_params.merge(d: "map"))
    @table_url = search_url(repeater_search_params.merge(d: "table"))
  end
end
