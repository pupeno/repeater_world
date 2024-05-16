# Copyright 2023, Pablo Fernandez
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Repeater World is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
# <https://www.gnu.org/licenses/>.

class RepeaterSearchesController < ApplicationController
  TABS = [
    CARDS = "cards",
    MAP = "map",
    TABLE = "table"
  ]

  before_action :authenticate_user!, except: %i[new export]
  before_action :set_repeater_search, only: %i[show edit update destroy]
  before_action :set_selected_tab_and_tab_urls, only: %i[new show create update]

  def index
    @repeater_searches = current_user.repeater_searches.page(params[:p] || 1)
  end

  def new
    defaults = {distance: 8, distance_unit: RepeaterSearch::KM}
    @repeater_search = RepeaterSearch.new(defaults.merge(repeater_search_params[:s] || {}))
    @repeater_search.saving = false
    if repeater_search_params[:s].present?
      if @repeater_search.valid?
        @results = @repeater_search.run
        @results = if @selected_tab == RepeaterSearchesController::MAP
          @results.where("location IS NOT NULL")
        else
          @results.page(params[:p] || 1)
        end
      end
    end

    if params[:export]
      @export_url = export_url(repeater_search_params)
    end

    @repeater_search.name = generate_human_name(@repeater_search)
  end

  def export
    safe_params = repeater_search_params
    if safe_params[:id].present?
      @repeater_search = RepeaterSearch.new(safe_params[:s])
    else
      defaults = {distance: 8, distance_unit: RepeaterSearch::KM}
      @repeater_search = RepeaterSearch.new(defaults.merge(safe_params[:s] || {}))
    end
    exporter_class = Exporters::EXPORTER_FOR[safe_params.dig(:e, :format)&.to_sym]
    if exporter_class.blank?
      raise ActionController::BadRequest, "Exporter format \"#{safe_params.dig(:e, :format)}\" not recognized, it should be one of #{Exporters::EXPORTER_FOR.keys}"
    end
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
    @results = @repeater_search.run
    @results = if @selected_tab == RepeaterSearchesController::MAP
      @results.where("location IS NOT NULL")
    else
      @results.page(params[:p] || 1)
    end
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

  def generate_human_name(repeater_search)
    # TODO: this is very problematic to internationalize, find a better way of doing this.
    modes = if repeater_search.all_modes?
      ["all modes"]
    else
      RepeaterSearch::MODES.map { |band| band[:label] if repeater_search.send(band[:pred]) }.compact
    end
    modes = modes.to_sentence

    bands = if repeater_search.all_bands?
      ["all bands"]
    else
      RepeaterSearch::BANDS.map { |band| band[:label] if repeater_search.send(band[:pred]) }.compact
    end
    bands = "on #{bands.to_sentence}" if bands.present?

    geo = if repeater_search.geosearch_type == RepeaterSearch::MY_LOCATION
      "within #{repeater_search.distance}#{repeater_search.distance_unit} of my location (#{repeater_search.latitude&.round(1)}, #{repeater_search.longitude&.round(1)})"
    elsif repeater_search.geosearch_type == RepeaterSearch::PLACE
      "within #{repeater_search.distance}#{repeater_search.distance_unit} of #{repeater_search.place} (#{repeater_search.latitude&.round(1)}, #{repeater_search.longitude&.round(1)})"
    elsif repeater_search.geosearch_type == RepeaterSearch::COORDINATES
      "within #{repeater_search.distance}#{repeater_search.distance_unit} of coordinates #{repeater_search.latitude&.round(3)}, #{repeater_search.longitude&.round(3)}"
    elsif repeater_search.geosearch_type == RepeaterSearch::GRID_SQUARE
      "within #{repeater_search.distance}#{repeater_search.distance_unit} of grid square #{repeater_search.grid_square} (#{repeater_search.latitude&.round(1)}, #{repeater_search.longitude&.round(1)})"
    elsif repeater_search.geosearch_type == RepeaterSearch::WITHIN_A_COUNTRY
      "within #{repeater_search.country.name}"
    end

    terms = if repeater_search.search_terms.present?
      "containing \"#{repeater_search.search_terms}\""
    end
    [modes, bands, terms, geo].reject(&:blank?).join(" ").upcase_first
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_repeater_search
    @repeater_search = current_user.repeater_searches.find(params[:id])
  end

  def repeater_search_params
    fields = [:name, :search_terms, :geosearch_type, :distance, :distance_unit, :place, :latitude, :longitude,
      :grid_square, :country_id]
    fields += RepeaterSearch::BANDS.map { |band| band[:name] }
    fields += RepeaterSearch::MODES.map { |mode| mode[:name] }
    params.permit(
      :id, # Id of the record, when it's saved
      :d, # Display mode, like cards, maps, table.
      s: fields, # Fields in the RepeaterSearch model.
      e: [:format] # Whether to export and what format.
    )
  end

  def set_selected_tab_and_tab_urls
    @selected_tab = (params[:d].present? && params[:d].in?(TABS)) ? params[:d] : CARDS
    @cards_url = search_url(repeater_search_params.merge(d: CARDS))
    @map_url = search_url(repeater_search_params.merge(d: MAP))
    @table_url = search_url(repeater_search_params.merge(d: TABLE))
  end
end
