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


class Api::Next::RepeatersController < ApplicationController
  def index
    # This API explicitly sets columns/field names in the response to make sure that as the model evolves, the API is
    # stable and it doesn't change. This is so that people can build applications on top of this API with confidence.
    # Currently the version of this API is "next" which means it's unstable, as we expect the model to evolve a little
    # bit. Once we're happy with the model, we'll change the version to "v1" and then we'll be stuck with it.

    @repeaters = Repeater.all.includes(:country)

    respond_to do |format|
      format.json { render }
      format.csv do
        columns = [
          :name, :call_sign, :web_site, :keeper, :band, :operational, :tx_frequency, :rx_frequency, :fm, :access_method,
          :ctcss_tone, :dstar, :fusion, :dmr, :dmr_color_code, :dmr_network, :nxdn, :address, :locality, :region,
          :post_code, :country_id, :country_name, :grid_square, :latitude, :longitude, :channel, :source, :utc_offset,
          :redistribution_limitations, :notes
        ]

        csv = CSV.generate(headers: columns, write_headers: true) do |csv|
          @repeaters.each do |repeater|
            csv << [repeater.name, repeater.call_sign, repeater.web_site, repeater.keeper, repeater.band,
              repeater.operational, repeater.tx_frequency, repeater.rx_frequency, repeater.fm,
              repeater.access_method, repeater.ctcss_tone, repeater.dstar, repeater.fusion, repeater.dmr,
              repeater.dmr_color_code, repeater.dmr_network, repeater.nxdn, repeater.address, repeater.locality,
              repeater.region, repeater.post_code, repeater.country_id, repeater.country.name,
              repeater.grid_square, repeater.latitude, repeater.longitude, repeater.channel, repeater.source,
              repeater.utc_offset, repeater.redistribution_limitations, repeater.notes]
          end
        end

        send_data(csv, filename: "repeaters.csv", disposition: "inline")
      end
    end
  end
end
