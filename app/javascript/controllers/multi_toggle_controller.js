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
  static targets = ["more", "all"]

  connect() {
    this.allTarget.addEventListener("change", this.updateStatusOfOtherButton.bind(this))

    this.otherCheckboxes = Array.from(this.element.querySelectorAll(`input[type=checkbox]`))
    this.otherCheckboxes = this.otherCheckboxes.filter((checkbox) => checkbox !== this.allTarget)
    this.otherCheckboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", this.updateStatusOfAllButton.bind(this))
    })

    this.showButtonsThatArePressed()
    this.updateStatusOfAllButton()
  }

  disconnect() {
    this.allTarget.removeEventListener("change", this.updateStatusOfOtherButton.bind(this))
    this.otherCheckboxes.forEach((checkbox) => {
      checkbox.removeEventListener("change", this.updateStatusOfAllButton.bind(this))
    })
  }

  updateStatusOfAllButton() {
    let shouldCheck = Array.from(this.otherCheckboxes).filter((checkbox) => checkbox.checked).length === 0
    if (shouldCheck !== this.allTarget.checked) {
      this.allTarget.checked = shouldCheck
      let controller = this.application.getControllerForElementAndIdentifier(this.allTarget.parentElement, "toggle-button")
      if (controller) {
        controller.updateButtonState()
      }
    }
  }

  updateStatusOfOtherButton(event) {
    if (event.target.checked) {
      this.otherCheckboxes.forEach((checkbox) => {
        checkbox.checked = false
        let controller = this.application.getControllerForElementAndIdentifier(checkbox.parentElement, "toggle-button")
        if (controller) {
          controller.updateButtonState()
        }
      })
    } else {
      this.allTarget.checked = true
      let controller = this.application.getControllerForElementAndIdentifier(this.allTarget.parentElement, "toggle-button")
      if (controller) {
        controller.updateButtonState()
      }
    }
  }

  showMore(event) {
    event.preventDefault()
    this.otherCheckboxes.forEach((checkbox) => {
      checkbox.parentElement.classList.remove("hidden")
    })
    this.moreTarget.classList.add("hidden")
  }

  // Show the buttons that are toggled on. The rest needs to click on "More" to be shown. See showMore()
  showButtonsThatArePressed() {
    this.otherCheckboxes.forEach((checkbox) => {
      if (checkbox.parentElement.classList.contains("hidden") && checkbox.checked) {
        checkbox.parentElement.classList.remove("hidden")
      }
    })
  }
}
