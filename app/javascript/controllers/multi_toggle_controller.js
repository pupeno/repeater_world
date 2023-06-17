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
import {WHEN_CHECKED, WHEN_UNCHECKED} from "controllers/toggle_button_controller"

export default class extends Controller {
  static targets = ["more", "all", "toggle"]

  connect() {
    this.showButtonsThatArePressed()
    this.updateStatusOfAllButton()
  }

  selectAll(event) {
    event.preventDefault()
    this.toggleTargets.forEach((toggle) => {
      this.getCheckbox(toggle).checked = false
      this.application.getControllerForElementAndIdentifier(toggle, "toggle-button")?.updateButtonState()
    })
    this.allTarget.classList.remove(...WHEN_UNCHECKED)
    this.allTarget.classList.add(...WHEN_CHECKED)
  }

  updateStatusOfAllButton() {
    const anyButtonsChecked = this.toggleTargets.filter((toggle) => this.getCheckbox(toggle).checked).length !== 0
    if (anyButtonsChecked) {
      this.allTarget.classList.remove(...WHEN_CHECKED)
      this.allTarget.classList.add(...WHEN_UNCHECKED)
    } else {
      this.allTarget.classList.remove(...WHEN_UNCHECKED)
      this.allTarget.classList.add(...WHEN_CHECKED)
    }
  }

  showMore(event) {
    event.preventDefault()
    this.toggleTargets.forEach((toggle) => {
      toggle.classList.remove("hidden")
    })
    this.moreTarget.classList.add("hidden")
  }

  // Show the buttons that are toggled on. The rest needs to click on "More" to be shown. See showMore()
  showButtonsThatArePressed() {
    this.toggleTargets.forEach((toggle) => {
      if (toggle.classList.contains("hidden") && this.getCheckbox(toggle).checked) {
        toggle.classList.remove("hidden")
      }
    })
    if (this.toggleTargets.filter((toggle) => toggle.classList.contains("hidden")).length === 0) {
      this.moreTarget.classList.add("hidden")
    }
  }

  getCheckbox(element) {
    return element.querySelectorAll("input[type=checkbox]")[0]
  }
}
