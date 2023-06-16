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

export default class extends Controller {
  static values = {
    all: String
  }

  connect() {
    this.allCheckbox = this.element.querySelectorAll(`input[type=checkbox][id*="${this.allValue}"]`)[0]
    this.allCheckbox.addEventListener("change", this.updateStatusOfOtherButton.bind(this))

    this.otherCheckboxes = this.element.querySelectorAll(`input[type=checkbox]`)
    this.otherCheckboxes = Array.from(this.otherCheckboxes).filter((checkbox) => checkbox !== this.allCheckbox)
    Array.from(this.otherCheckboxes).forEach((checkbox) => {
      checkbox.addEventListener("change", this.updateStatusOfAllButton.bind(this))
    })

    this.updateStatusOfAllButton()
  }

  disconnect() {
    this.allCheckbox.removeEventListener("change", this.updateStatusOfOtherButton.bind(this))
    Array.from(this.otherCheckboxes).forEach((checkbox) => {
      checkbox.removeEventListener("change", this.updateStatusOfAllButton.bind(this))
    })
  }

  updateStatusOfAllButton() {
    let shouldCheck = Array.from(this.otherCheckboxes).filter((checkbox) => checkbox.checked).length === 0
    if (shouldCheck !== this.allCheckbox.checked) {
      this.allCheckbox.checked = shouldCheck
      let controller = this.application.getControllerForElementAndIdentifier(this.allCheckbox.parentElement, "toggle-button")
      if (controller) controller.updateButtonState()
    }
  }

  updateStatusOfOtherButton(event) {
    if (event.target.checked) {
      Array.from(this.otherCheckboxes).forEach((checkbox) => {
        checkbox.checked = false
        let controller = this.application.getControllerForElementAndIdentifier(checkbox.parentElement, "toggle-button")
        if (controller) controller.updateButtonState()
      })
    } else {
      this.allCheckbox.checked = true
      let controller = this.application.getControllerForElementAndIdentifier(this.allCheckbox.parentElement, "toggle-button")
      if (controller) controller.updateButtonState()
    }
  }
}
