/* Copyright 2023-2024, Pablo Fernandez
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

export default class extends Controller {
  static targets = [
    "type",
    "myLocationFields", "coordinatesFields", "gridSquareFields", "placeFields", "withinACountryFields",
    "latitude", "longitude",
  ]

  connect() {
    this.updateState()
  }

  updateState() {
    if (this.typeTarget.value === "") { // Nothing is selected.
      this.hideAllFields()
    } else if (this.typeTarget.value === "my_location") {
      this.hideAllFields()
      this.myLocationFieldsTargets.forEach(e => e.classList.remove("hidden"))
      this.geolocate()
    } else if (this.typeTarget.value === "coordinates") {
      this.hideAllFields()
      this.coordinatesFieldsTargets.forEach(e => e.classList.remove("hidden"))
    } else if (this.typeTarget.value === "grid_square") {
      this.hideAllFields()
      this.gridSquareFieldsTargets.forEach(e => e.classList.remove("hidden"))
    } else if (this.typeTarget.value === "place") {
      this.hideAllFields()
      this.placeFieldsTargets.forEach(e => e.classList.remove("hidden"))
    } else if (this.typeTarget.value === "within_a_country") {
      this.hideAllFields()
      this.withinACountryFieldsTargets.forEach(e => e.classList.remove("hidden"))
    } else {
      throw `Unexpected type of geosearch : ${this.typeTarget.value}`
    }
  }

  hideAllFields() {
    this.myLocationFieldsTargets.forEach(e => e.classList.add("hidden"))
    this.placeFieldsTargets.forEach(e => e.classList.add("hidden"))
    this.coordinatesFieldsTargets.forEach(e => e.classList.add("hidden"))
    this.gridSquareFieldsTargets.forEach(e => e.classList.add("hidden"))
    this.withinACountryFieldsTargets.forEach(e => e.classList.add("hidden"))
  }

  geolocate() {
    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition((position) => {
        this.latitudeTarget.value = position.coords.latitude
        this.longitudeTarget.value = position.coords.longitude
      }, (error) => {
        switch (error.code) {
          case GeolocationPositionError.PERMISSION_DENIED:
            alert("We are having trouble getting the location from your browser. Make sure you are granting us enough permissions. You can still enter your coordinates manually.")
            break
          case GeolocationPositionError.POSITION_UNAVAILABLE:
          case GeolocationPositionError.TIMEOUT:
            alert("We are having trouble getting the location from your browser. You can still enter your coordinates manually.")
            break
        }
        this.typeTarget.value = "coordinates"
        this.updateState()
      })
    } else {
      alert("We are sorry, but your browser doesn't seem to support geolocation. You can still enter your coordinates manually.")
      this.typeTarget.value = "coordinates"
      this.updateState()
    }
  }
}
