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
  json.fm_tone_burst repeater.fm_tone_burst
  json.fm_ctcss_tone repeater.fm_ctcss_tone
  json.fm_tone_squelch repeater.fm_tone_squelch
  json.dstar repeater.dstar
  json.fusion repeater.fusion
  json.dmr repeater.dmr
  json.dmr_color_code repeater.dmr_color_code
  json.dmr_network repeater.dmr_network
  json.nxdn repeater.nxdn
  json.p25 repeater.p25
  json.tetra repeater.tetra
  json.latitude repeater.latitude
  json.longitude repeater.longitude
  json.grid_square repeater.grid_square
  json.address repeater.address
  json.locality repeater.locality
  json.region repeater.region
  json.post_code repeater.post_code
  json.country_id repeater.country_id
  json.tx_power repeater.tx_power
  json.tx_antenna repeater.tx_antenna
  json.tx_antenna_polarization repeater.tx_antenna_polarization
  json.rx_antenna repeater.rx_antenna
  json.rx_antenna_polarization repeater.rx_antenna_polarization
  json.altitude_asl repeater.altitude_asl
  json.altitude_agl repeater.altitude_agl
  json.bearing repeater.bearing
  json.utc_offset repeater.utc_offset
  json.channel repeater.channel
  json.notes repeater.notes
  json.source repeater.source
  json.redistribution_limitations repeater.redistribution_limitations
  json.external_id repeater.external_id
end
