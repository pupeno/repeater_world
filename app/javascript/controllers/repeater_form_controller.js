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
  static targets = [
    "fmCheckbox", "fmSection",
    "m17Checkbox", "m17Section",
    "dstarCheckbox", "dstarSection",
    "fusionCheckbox", "fusionSection",
    "dmrCheckbox", "dmrSection",
    "echolinkCheckbox", "echolinkSection",
    "countrySelect", "regionsSelectForWorld", "regionsSelectForUsa", "regionsSelectForCanada"]

  connect() {
    this.updateFmSectionState();
    this.updateM17SectionState();
    this.updateDstarSectionState();
    this.updateFusionSectionState();
    this.updateDmrSectionState();
    this.updateEcholinkSectionState();
    this.updateRegionSelectState();
  }

  fmChanged() {
    this.updateFmSectionState();
  }

  updateFmSectionState() {
    if (this.fmCheckboxTarget.checked) {
      this.fmSectionTarget.classList.remove("hidden")
    } else {
      this.fmSectionTarget.classList.add("hidden")
    }
  }

  m17Changed() {
    this.updateM17SectionState();
  }

  updateM17SectionState() {
    if (this.m17CheckboxTarget.checked) {
      this.m17SectionTarget.classList.remove("hidden")
    } else {
      this.m17SectionTarget.classList.add("hidden")
    }
  }

  dstarChanged() {
    this.updateDstarSectionState();
  }

  updateDstarSectionState() {
    if (this.dstarCheckboxTarget.checked) {
      this.dstarSectionTarget.classList.remove("hidden")
    } else {
      this.dstarSectionTarget.classList.add("hidden")
    }
  }

  fusionChanged() {
    this.updateFusionSectionState();
  }

  updateFusionSectionState() {
    if (this.fusionCheckboxTarget.checked) {
      this.fusionSectionTarget.classList.remove("hidden")
    } else {
      this.fusionSectionTarget.classList.add("hidden")
    }
  }

  dmrChanged() {
    this.updateDmrSectionState();
  }

  updateDmrSectionState() {
    if (this.dmrCheckboxTarget.checked) {
      this.dmrSectionTarget.classList.remove("hidden")
    } else {
      this.dmrSectionTarget.classList.add("hidden")
    }
  }

  echolinkChanged() {
    this.updateEcholinkSectionState();
  }

  updateEcholinkSectionState() {
    if (this.echolinkCheckboxTarget.checked) {
      this.echolinkSectionTarget.classList.remove("hidden")
    } else {
      this.echolinkSectionTarget.classList.add("hidden")
    }
  }

  countryChange() {
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
