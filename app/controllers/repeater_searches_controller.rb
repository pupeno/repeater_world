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

  # TODO: implement
  # def index
  #   @repeater_searches = RepeaterSearch.all
  # end

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
      redirect_to @repeater_search
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
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
        redirect_to @repeater_search
      end
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
    params.permit(
      :d,
      s: Repeater::BANDS.map { |b| :"band_#{b}" } +
        Repeater::MODES +
        [:distance_to_coordinates, :distance, :distance_unit, :latitude, :longitude],
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
