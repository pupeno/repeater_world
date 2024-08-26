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

  updateFmSectionState() {
    this.showHideSection(this.fmCheckboxTarget, this.fmSectionTarget);
  }

  updateM17SectionState() {
    this.showHideSection(this.m17CheckboxTarget, this.m17SectionTarget);
  }

  updateDstarSectionState() {
    this.showHideSection(this.dstarCheckboxTarget, this.dstarSectionTarget);
  }

  updateFusionSectionState() {
    this.showHideSection(this.fusionCheckboxTarget, this.fusionSectionTarget);
  }

  updateDmrSectionState() {
    this.showHideSection(this.dmrCheckboxTarget, this.dmrSectionTarget);
  }

  updateEcholinkSectionState() {
    this.showHideSection(this.echolinkCheckboxTarget, this.echolinkSectionTarget);
  }

  showHideSection(checkbox, section) {
    if (checkbox.checked) {
      section.classList.remove("hidden")
    } else {
      section.classList.add("hidden")
    }
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
