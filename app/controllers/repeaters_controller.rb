# Copyright 2023-2024, Pablo Fernandez
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

class RepeatersController < ApplicationController
  def show
    begin
      @repeater = Repeater.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @repeater = Repeater.find_by_id(params[:id].split("-").take(5).join("-")) # Old "slug", starting with the UUID of the record.
      raise if @repeater.blank?
    end
    if request.path != repeater_path(@repeater)
      redirect_to @repeater, status: :moved_permanently
    end
  end

  def new
    @repeater = Repeater.new
  end

  def create
    @repeater = Repeater.new(repeater_params)
    if @repeater.save
      redirect_to @repeater, notice: "Thank you, this repeater is now live"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def repeater_params
    params.fetch(:repeater, {}).permit(
      :altitude_agl,
      :altitude_asl,
      :band,
      :bearing,
      :call_sign,
      :channel,
      :cross_band,
      :dmr,
      :dmr_color_code,
      :dmr_network,
      :dstar,
      :dstar_port,
      :echolink,
      :echolink_node_number,
      :fm,
      :fm_ctcss_tone,
      :fm_tone_burst,
      :fm_tone_squelch,
      :fusion,
      :grid_square,
      :input_address,
      :input_country_id,
      :input_latitude,
      :input_locality,
      :input_longitude,
      :input_post_code,
      :input_region,
      :keeper,
      :m17,
      :m17_can,
      :m17_reflector_name,
      :name,
      :notes,
      :nxdn,
      :p25,
      :private_notes,
      :rx_antenna,
      :rx_antenna_polarization,
      :rx_frequency,
      :tetra,
      :tx_antenna,
      :tx_antenna_polarization,
      :tx_frequency,
      :tx_power,
      :web_site,
      :wires_x_node_id
    )
  end
end
