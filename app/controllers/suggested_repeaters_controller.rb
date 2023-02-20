# Copyright 2023, Pablo Fernandez
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

class SuggestedRepeatersController < ApplicationController
  def new
    @suggested_repeater = SuggestedRepeater.new
  end

  def create
    @suggested_repeater = SuggestedRepeater.new(suggested_repeater_params)
    @suggested_repeater.save
    redirect_to new_suggested_repeater_url,
      notice: "Thank you for helping us grow by adding a repeater. We'll review it and let you know when we added it. Do you have any other?"
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
      :submitter_name, :submitter_email, :submitter_call_sign, :submitter_keeper, :submitter_notes, :name, :call_sign,
      :band, :channel, :keeper, :notes, :web_site, :tx_frequency, :rx_frequency, :fm, :access_method, :ctcss_tone,
      :tone_sql, :dstar, :fusion, :dmr, :dmr_color_code, :dmr_network, :nxdn, :latitude, :longitude, :grid_square,
      :address, :locality, :region, :post_code, :country
    )
  end
end
