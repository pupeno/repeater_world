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
import * as Sentry from "@sentry/browser"
import {MarkerClusterer} from "@googlemaps/markerclusterer"

// This just comes from https://developers.google.com/maps/documentation/javascript/examples/style-array#maps_style_array-javascript
const DARK_MODE_STYLES = [
  {elementType: "geometry", stylers: [{color: "#242f3e"}]},
  {elementType: "labels.text.stroke", stylers: [{color: "#242f3e"}]},
  {elementType: "labels.text.fill", stylers: [{color: "#746855"}]},
  {
    featureType: "administrative.locality",
    elementType: "labels.text.fill",
    stylers: [{color: "#d59563"}],
  },
  {
    featureType: "poi",
    elementType: "labels.text.fill",
    stylers: [{color: "#d59563"}],
  },
  {
    featureType: "poi.park",
    elementType: "geometry",
    stylers: [{color: "#263c3f"}],
  },
  {
    featureType: "poi.park",
    elementType: "labels.text.fill",
    stylers: [{color: "#6b9a76"}],
  },
  {
    featureType: "road",
    elementType: "geometry",
    stylers: [{color: "#38414e"}],
  },
  {
    featureType: "road",
    elementType: "geometry.stroke",
    stylers: [{color: "#212a37"}],
  },
  {
    featureType: "road",
    elementType: "labels.text.fill",
    stylers: [{color: "#9ca5b3"}],
  },
  {
    featureType: "road.highway",
    elementType: "geometry",
    stylers: [{color: "#746855"}],
  },
  {
    featureType: "road.highway",
    elementType: "geometry.stroke",
    stylers: [{color: "#1f2835"}],
  },
  {
    featureType: "road.highway",
    elementType: "labels.text.fill",
    stylers: [{color: "#f3d19c"}],
  },
  {
    featureType: "transit",
    elementType: "geometry",
    stylers: [{color: "#2f3948"}],
  },
  {
    featureType: "transit.station",
    elementType: "labels.text.fill",
    stylers: [{color: "#d59563"}],
  },
  {
    featureType: "water",
    elementType: "geometry",
    stylers: [{color: "#17263c"}],
  },
  {
    featureType: "water",
    elementType: "labels.text.fill",
    stylers: [{color: "#515c6d"}],
  },
  {
    featureType: "water",
    elementType: "labels.text.stroke",
    stylers: [{color: "#17263c"}],
  },
]

export default class extends Controller {
  static values = {
    home: Object,
    markers: Array
  }

  connect() {
    if (typeof (google) != "undefined") {
      this.initializeMap()
    }
  }

  initializeMap() {
    let center = {lat: 0, lng: 0}
    if (this.hasHomeValue && this.homeValue.lat) {
      center = {lat: this.homeValue.lat, lng: this.homeValue.lng}
    } else if (this.markersValue[0]) {
      center = {lat: this.markersValue[0].lat, lng: this.markersValue[0].lng}
    }

    let map = new google.maps.Map(this.element, {
      center: center,
      zoom: 2,
      styles: this.getLightOrDarkMapStyles()
    })

    this.initializeLightDarkChanger(map, this)

    let bounds = new google.maps.LatLngBounds()

    if (this.hasHomeValue && this.homeValue.lat) {
      let isInfoWindowOpen = false
      let mapMarker = new google.maps.Marker({
        map,
        position: {lat: this.homeValue.lat, lng: this.homeValue.lng},
        title: "This is where you are",
        icon: {
          url: CROSSHAIRS_MAP_MARKER,
          scaledSize: {width: 40, height: 40},
          anchor: {x: 20, y: 20}
        }
      })
      const infoWindow = new google.maps.InfoWindow({
        content: this.homeValue.info,
        ariaLabel: "label",
      })
      mapMarker.addListener("click", () => {
        if (isInfoWindowOpen) {
          infoWindow.close()
        } else {
          infoWindow.open({anchor: mapMarker, map})
        }
        isInfoWindowOpen = !isInfoWindowOpen
      })
      bounds.extend(new google.maps.LatLng(this.homeValue.lat, this.homeValue.lng))
    }

    const markers = this.markersValue.map(marker => {
      if (typeof marker.lat !== "number" || typeof marker.lng !== "number") {
        Sentry.captureMessage(`Invalid coordinates for marker: ${marker}`)
        return null
      }

      let isInfoWindowOpen = false
      const infoWindow = new google.maps.InfoWindow({
        content: marker.info,
        ariaLabel: "label",
      })
      let mode = "multi"
      if (marker.modes.length === 1) {
        mode = marker.modes[0]
      }
      const iconScalingFactor = 20
      let randomizationFactor = 0.001
      let lat = marker.lat + Math.random() * randomizationFactor - randomizationFactor / 2
      let lng = marker.lng + Math.random() * randomizationFactor - randomizationFactor / 2
      const mapMarker = new google.maps.Marker({
        position: {lat: lat, lng: lng},
        title: marker.tooltip,
        icon: {
          url: REPEATER_MAP_MARKERS[marker.band][mode],
          scaledSize: {width: 600 / iconScalingFactor, height: 1000 / iconScalingFactor}
        }
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
    }).filter(x => x)

    new MarkerClusterer({markers, map})

    // Don't allow fitBounds to zoom in too much (it happens when there's only 1 repeater for example).
    google.maps.event.addListenerOnce(map, "bounds_changed", function () {
      if (map.getZoom() > 13) {
        map.setZoom(13)
      }
    })
    map.fitBounds(bounds)
  }

  initializeLightDarkChanger(map, this_) {
    let observer = new MutationObserver(function (_event) {
      map.setOptions({styles: this_.getLightOrDarkMapStyles()})
    })
    observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class'],
      childList: false,
      characterData: false
    })
  }

  getLightOrDarkMapStyles() {
    return document.documentElement.classList.contains('dark') ? DARK_MODE_STYLES : null
  }
}
