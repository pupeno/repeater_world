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

json.array! @repeaters do |repeater|
  json.name repeater.name
  json.call_sign repeater.call_sign
  json.web_site repeater.web_site
  json.keeper repeater.keeper
  json.band repeater.band
  json.operational repeater.operational
  json.tx_frequency repeater.tx_frequency
  json.rx_frequency repeater.rx_frequency
  json.fm repeater.fm
  json.access_method repeater.access_method
  json.ctcss_tone repeater.ctcss_tone
  json.dstar repeater.dstar
  json.fusion repeater.fusion
  json.dmr repeater.dmr
  json.dmr_color_code repeater.dmr_color_code
  json.dmr_network repeater.dmr_network
  json.nxdn repeater.nxdn
  json.address repeater.address
  json.locality repeater.locality
  json.region repeater.region
  json.post_code repeater.post_code
  json.country_code repeater.country_id
  json.country_name repeater.country.name
  json.grid_square repeater.grid_square
  json.location [repeater.latitude, repeater.longitude]
  json.channel repeater.channel
  json.source repeater.source
  json.utc_offset repeater.utc_offset
  json.redistribution_limitations repeater.redistribution_limitations
  json.notes repeater.notes
end
