/* Copyright 2023, Flexpoint Tech
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

const GRAYED_OUT_TEXT = "text-gray-300"
const NORMAL_TEXT = "text-gray-900"

export default class extends Controller {
  static targets = ["activator", "controlled", "type", "coordinatesFields", "latitude", "longitude"]

  connect() {
    this.updateState()
  }

  updateState() {
    if (this.activatorTarget.checked) {
      this.controlledTargets.forEach(element => {
        element.classList.remove(GRAYED_OUT_TEXT)
        element.classList.add(NORMAL_TEXT)
      })
    } else {
      this.controlledTargets.forEach(element => {
        element.classList.remove(NORMAL_TEXT)
        element.classList.add(GRAYED_OUT_TEXT)
      })
    }
    if (this.typeTarget.value === "my_location") {
      this.coordinatesFieldsTarget.classList.add("hidden")
      if (this.activatorTarget.checked) {
        this.geolocate()
      }
    } else if (this.typeTarget.value === "coordinates") {
      this.coordinatesFieldsTarget.classList.remove("hidden")
    } else {
      throw `Unexpected type of geosearch : ${this.typeTarget.value}`
    }
  }

  enable() {
    if (!this.activatorTarget.checked) {
      this.activatorTarget.checked = true
      this.activatorTarget.dispatchEvent(new Event("change"))
      this.updateState()
    }
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
