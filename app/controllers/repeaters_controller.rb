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
  before_action :set_repeater, only: %i[show edit update]

  def show
    if request.path != repeater_path(@repeater)
      redirect_to @repeater, status: :moved_permanently
    end
  end

  def new
    @repeater = Repeater.new
    authorize @repeater
  rescue Pundit::NotAuthorizedError
    cannot_add_repeater!
  end

  def create
    @repeater = Repeater.new(repeater_params)
    authorize @repeater
    if @repeater.save
      ActionMailer::Base.mail(
        from: "Repeater World <info@repeater.world>",
        to: "Repeater World <info@repeater.world>",
        subject: "New repeater added #{@repeater.moniker}",
        body: "New repeater added #{@repeater.moniker} #{@repeater} by #{current_user}"
      ).deliver
      redirect_to @repeater, notice: "Thank you. Your repeater is now live."
    else
      render :new, status: :unprocessable_entity
    end
  rescue Pundit::NotAuthorizedError
    cannot_add_repeater!
  end

  def edit
    authorize @repeater
    if request.path != edit_repeater_path(@repeater)
      redirect_to edit_repeater_url(@repeater), status: :moved_permanently
    end
  rescue Pundit::NotAuthorizedError
    cannot_edit_repeater!
  end

  def update
    authorize @repeater
    @repeater.source = nil
    @repeater.redistribution_limitations = nil
    if @repeater.update(repeater_params)
      ActionMailer::Base.mail(
        from: "Repeater World <info@repeater.world>",
        to: "Repeater World <info@repeater.world>",
        subject: "Repeater updated #{@repeater.moniker}",
        body: "Repeater updated #{@repeater.moniker} #{@repeater} by #{current_user}"
      ).deliver
      redirect_to repeater_url(@repeater), notice: "Thank you. The details for this repeater have been updated."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue Pundit::NotAuthorizedError
    cannot_edit_repeater!
  end

  private

  def set_repeater
    @repeater = Repeater.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    @repeater = Repeater.find_by_id(params[:id].split("-").take(5).join("-")) # Old "slug", starting with the UUID of the record.
    raise if @repeater.blank?
  end

  def cannot_add_repeater!
    redirect_to new_user_registration_url, alert: "To be able to create repeaters you need to sign up or log in."
  end

  def cannot_edit_repeater!
    if user_signed_in?
      redirect_to @repeater, alert: "To be able to edit repeaters you need to get in touch with us at info@repeater.world."
    else
      redirect_to new_user_registration_url, alert: "To be able to edit repeaters you need to log in or sign up. If you are signing up with a new account, you also need to reach out to info@repeater.world to have editing repeaters activated."
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
      :input_grid_square,
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
