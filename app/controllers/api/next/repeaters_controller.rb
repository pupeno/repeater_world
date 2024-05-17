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

class Api::Next::RepeatersController < ApplicationController
  def index
    # This API explicitly sets columns/field names in the response to make sure that as the model evolves, the API is
    # stable and it doesn't change. This is so that people can build applications on top of this API with confidence.
    # Currently the version of this API is "next" which means it's unstable, as we expect the model to evolve a little
    # bit. Once we're happy with the model, we'll change the version to "v1" and then we'll be stuck with it.

    @repeaters = Repeater.all.includes(:country)
    @fields = [
      :name, :call_sign, :web_site, :keeper, :band, :operational, :tx_frequency, :rx_frequency,
      :fm, :fm_tone_burst, :fm_ctcss_tone, :fm_tone_squelch, :bandwidth,
      :dstar, :dstar_port,
      :fusion,
      :dmr, :dmr_color_code, :dmr_network,
      :nxdn, :p25, :tetra,
      :latitude, :longitude, :grid_square, :address, :locality, :region, :post_code, :country_id,
      :tx_power, :tx_antenna, :tx_antenna_polarization, :rx_antenna, :rx_antenna_polarization,
      :altitude_asl, :altitude_agl, :bearing,
      :utc_offset, :channel, :notes, :source, :redistribution_limitations, :external_id
    ]

    respond_to do |format|
      format.json { render }
      format.csv do
        csv = CSV.generate(headers: @fields, write_headers: true) do |csv|
          @repeaters.each do |repeater|
            csv << @fields.map { |column| repeater.send(column) }
          end
        end

        send_data(csv, filename: "repeaters.csv", disposition: "inline")
      end
    end
  end
end
