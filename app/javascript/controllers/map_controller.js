/* Copyright 2023, Pablo Fernandez
 *
 * This file is part of Repeater World.
 *
 * Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
 * Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * Repeater World is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied 
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more 
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
 * <https://www.gnu.org/licenses/>.
 */

import {Controller} from "@hotwired/stimulus"
import {MarkerClusterer} from "@googlemaps/markerclusterer"

export default class extends Controller {
  static values = {
    markers: Array
  }

  connect() {
    if (typeof (google) != "undefined") {
      this.initializeMap()
    }
  }

  initializeMap() {
    let map = new google.maps.Map(this.element, {center: {lat: 0, lng: 0}, zoom: 2})

    let bounds = new google.maps.LatLngBounds()

    const markers = this.markersValue.map(marker => {
      let isInfoWindowOpen = false
      const infoWindow = new google.maps.InfoWindow({
        content: marker.info,
        ariaLabel: "label",
      })
      const mapMarker = new google.maps.Marker({
        position: {lat: marker.lat, lng: marker.lng},
        title: marker.tooltip,
      })
      mapMarker.addListener("click", () => {
        if (isInfoWindowOpen) {
          infoWindow.close()
        } else {
          infoWindow.open({anchor: mapMarker, map})
        }
        isInfoWindowOpen = !isInfoWindowOpen
      })
      bounds.extend(new google.maps.LatLng(marker.lat, marker.lng))

      return mapMarker
    })

    new MarkerClusterer({markers, map})

    // Don't allow fitBounds to zoom in too much (it happens when there's only 1 repeater for example).
    google.maps.event.addListenerOnce(map, "bounds_changed", function () {
      if (map.getZoom() > 13) {
        map.setZoom(13)
      }
    })
    map.fitBounds(bounds)
  }
}
