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

export default class extends Controller {
  static targets = ["more", "all", "toggle"]

  connect() {
    this.allCheckBox = this.getCheckbox(this.allTarget)
    this.toggleCheckBoxes = this.toggleTargets.map(this.getCheckbox)

    this.allCheckBox.addEventListener("change", this.updateStatusOfOtherButton.bind(this))
    this.toggleCheckBoxes.forEach((checkbox) => {
      checkbox.addEventListener("change", this.updateStatusOfAllButton.bind(this))
    })

    this.showButtonsThatArePressed()
    this.updateStatusOfAllButton()
  }

  disconnect() {
    this.allCheckBox.removeEventListener("change", this.updateStatusOfOtherButton.bind(this))
    this.toggleCheckBoxes.forEach((checkbox) => {
      checkbox.removeEventListener("change", this.updateStatusOfAllButton.bind(this))
    })
  }

  updateStatusOfAllButton() {
    const shouldCheck = this.toggleTargets.filter((toggle) => this.getCheckbox(toggle).checked).length === 0
    if (shouldCheck !== this.allCheckBox.checked) {
      this.allCheckBox.checked = shouldCheck
      this.application.getControllerForElementAndIdentifier(this.allTarget, "toggle-button")?.updateButtonState()
    }
  }

  updateStatusOfOtherButton(event) {
    if (event.target.checked) {
      this.toggleTargets.forEach((toggle) => {
        this.getCheckbox(toggle).checked = false
        this.application.getControllerForElementAndIdentifier(toggle, "toggle-button")?.updateButtonState()
      })
    } else {
      this.allCheckBox.checked = true
      this.application.getControllerForElementAndIdentifier(this.allTarget, "toggle-button")?.updateButtonState()
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
  }

  getCheckbox(element) {
    return element.querySelectorAll("input[type=checkbox]")[0]
  }
}
