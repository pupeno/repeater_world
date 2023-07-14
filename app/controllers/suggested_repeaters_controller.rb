# Copyright 2023, Flexpoint Tech
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

class SuggestedRepeatersController < ApplicationController
  def new
    @suggested_repeater = SuggestedRepeater.new
    if params[:repeater_id] && Repeater.exists?(params[:repeater_id])
      @repeater = Repeater.find(params[:repeater_id])
      @suggested_repeater.repeater = @repeater
      @suggested_repeater.name = @repeater.name
      @suggested_repeater.call_sign = @repeater.call_sign
      @suggested_repeater.keeper = @repeater.keeper
      @suggested_repeater.notes = @repeater.notes
      @suggested_repeater.web_site = @repeater.web_site
      @suggested_repeater.tx_frequency = @repeater.tx_frequency
      @suggested_repeater.rx_frequency = @repeater.rx_frequency
      @suggested_repeater.fm = @repeater.fm
      @suggested_repeater.dstar = @repeater.dstar
      @suggested_repeater.fusion = @repeater.fusion
      @suggested_repeater.dmr = @repeater.dmr
      @suggested_repeater.nxdn = @repeater.nxdn
      @suggested_repeater.p25 = @repeater.p25
      @suggested_repeater.tetra = @repeater.tetra

      @suggested_repeater.fm_tone_burst = @repeater.fm_tone_burst
      @suggested_repeater.fm_ctcss_tone = @repeater.fm_ctcss_tone

      @suggested_repeater.dstar_port = @repeater.dstar_port

      @suggested_repeater.dmr_color_code = @repeater.dmr_color_code
      @suggested_repeater.dmr_network = @repeater.dmr_network

      @suggested_repeater.latitude = @repeater.latitude
      @suggested_repeater.longitude = @repeater.longitude
      @suggested_repeater.address = @repeater.address
      @suggested_repeater.locality = @repeater.locality
      @suggested_repeater.region = @repeater.region
      @suggested_repeater.post_code = @repeater.post_code
      @suggested_repeater.country_id = @repeater.country_id
      @suggested_repeater.grid_square = @repeater.grid_square
      
      @suggested_repeater.tx_antenna = @repeater.tx_antenna
      @suggested_repeater.tx_antenna_polarization = @repeater.tx_antenna_polarization
      @suggested_repeater.tx_power = @repeater.tx_power
      @suggested_repeater.rx_antenna = @repeater.rx_antenna
      @suggested_repeater.rx_antenna_polarization = @repeater.rx_antenna_polarization
      @suggested_repeater.bearing = @repeater.bearing
      @suggested_repeater.altitude_agl = @repeater.altitude_agl
      @suggested_repeater.altitude_asl = @repeater.altitude_asl
      @suggested_repeater.band = @repeater.band
      @suggested_repeater.channel = @repeater.channel
    end
  end

  def create
    @suggested_repeater = SuggestedRepeater.new(suggested_repeater_params)
    @suggested_repeater.save
    ActionMailer::Base.mail(
      from: "Repeater World <info@repeater.world>",
      to: "Repeater World <info@repeater.world>",
      subject: "New repeater added #{@suggested_repeater.name}",
      body: "New repeater added #{@suggested_repeater.name}"
    ).deliver
    redirect_to new_suggested_repeater_url,
      notice: "Thank you for helping us grow by adding or updating a repeater. We'll review it and let you know when the changes are added. Do you have any other?"
    # At the moment, there's no case in which saving fails, since there's no validations, but in case that gets added
    # in the future, this is the code that needs uncommenting:
    # if @suggested_repeater.save
    #   redirect_to new_suggested_repeater_url,
    #               notice: "Thank you for helping us grow by adding a repeater. We'll review it and let you know when we added it. Do you have any other?"
    # else
    #   render :new, status: :unprocessable_entity
    # end
  end

  private

  def suggested_repeater_params
    params.fetch(:suggested_repeater, {}).permit(
      :address,
      :altitude_agl,
      :altitude_asl,
      :band,
      :bearing,
      :call_sign,
      :channel,
      :country_id,
      :dmr,
      :dmr_color_code,
      :dmr_network,
      :dstar,
      :dstar_port,
      :fm,
      :fm_ctcss_tone,
      :fm_tone_burst,
      :fm_tone_squelch,
      :fusion,
      :grid_square,
      :keeper,
      :latitude,
      :locality,
      :longitude,
      :name,
      :notes,
      :nxdn,
      :p25,
      :post_code,
      :private_notes,
      :region,
      :rx_antenna,
      :rx_antenna_polarization,
      :rx_frequency,
      :submitter_call_sign,
      :submitter_email,
      :submitter_keeper,
      :submitter_name,
      :submitter_notes,
      :tetra,
      :tx_antenna,
      :tx_antenna_polarization,
      :tx_frequency,
      :tx_power,
      :web_site,
      :repeater_id
    )
  end
end
