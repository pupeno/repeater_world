/* Copyright 2023, Flexpoint Tech
 *
 * This file is part of Repeater World.
 *
 * Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
 * Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * Foobar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
 * <https://www.gnu.org/licenses/>.
 */

import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rxFreqAsFreq", "rxFreqAsOffset", "locationFormat1", "locationFormat2", "locationFormat3"]

  toggleRxFrequencyFormat() {
    if (this.rxFreqAsFreqTarget.classList.contains("hidden")) {
      this.rxFreqAsFreqTargets.forEach((x) => x.classList.remove("hidden"))
      this.rxFreqAsOffsetTargets.forEach((x) => x.classList.add("hidden"))
    } else {
      this.rxFreqAsFreqTargets.forEach((x) => x.classList.add("hidden"))
      this.rxFreqAsOffsetTargets.forEach((x) => x.classList.remove("hidden"))
    }
  }

  changeLocationFormat() {
    if (!this.locationFormat1Target.classList.contains("hidden")) {
      this.locationFormat1Targets.forEach((x) => x.classList.add("hidden"))
      this.locationFormat2Targets.forEach((x) => x.classList.remove("hidden"))
      this.locationFormat3Targets.forEach((x) => x.classList.add("hidden"))
    } else if (!this.locationFormat2Target.classList.contains("hidden")) {
      this.locationFormat1Targets.forEach((x) => x.classList.add("hidden"))
      this.locationFormat2Targets.forEach((x) => x.classList.add("hidden"))
      this.locationFormat3Targets.forEach((x) => x.classList.remove("hidden"))
    } else {
      this.locationFormat1Targets.forEach((x) => x.classList.remove("hidden"))
      this.locationFormat2Targets.forEach((x) => x.classList.add("hidden"))
      this.locationFormat3Targets.forEach((x) => x.classList.add("hidden"))
    }
  }
}
