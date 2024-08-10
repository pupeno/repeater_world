/* Copyright 2024, Pablo Fernandez
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
  static targets = ["countrySelect", "regionsSelectForWorld", "regionsSelectForUsa", "regionsSelectForCanada"]

  connect() {
    this.updateRegionSelectState();
  }

  countryChange(event) {
    this.updateRegionSelectState();
  }

  updateRegionSelectState() {
    this.regionsSelectForUsaTarget.classList.add("hidden")
    this.regionsSelectForUsaTarget.querySelector("select").disabled = true
    this.regionsSelectForCanadaTarget.classList.add("hidden")
    this.regionsSelectForCanadaTarget.querySelector("select").disabled = true
    this.regionsSelectForWorldTarget.classList.add("hidden")
    this.regionsSelectForWorldTarget.querySelector("input").disabled = true
    switch (this.countrySelectTarget.value) {
      case "us":
        this.regionsSelectForUsaTarget.classList.remove("hidden")
        this.regionsSelectForUsaTarget.querySelector("select").disabled = false
        break;
      case "ca":
        this.regionsSelectForCanadaTarget.classList.remove("hidden")
        this.regionsSelectForCanadaTarget.querySelector("select").disabled = false
        break;
      default:
        this.regionsSelectForWorldTarget.classList.remove("hidden")
        this.regionsSelectForWorldTarget.querySelector("input").disabled = false
        break;
    }
  }
}
