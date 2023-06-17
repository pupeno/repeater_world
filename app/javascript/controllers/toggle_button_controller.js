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
  connect() {
    this.checkbox = this.element.querySelectorAll('input[type=checkbox]')[0]
    this.label = this.element
    this.updateButtonState()
  }

  updateButtonState() {
    const whenChecked = ["ring-2", "ring-orange-600", "ring-offset-2", "bg-orange-600", "text-white", "hover:bg-orange-500"]
    const whenUnchecked = ["ring-1", "ring-inset", "ring-orange-300", "bg-white", "text-gray-900", "hover:bg-orange-50"]

    if (this.checkbox.checked) {
      this.label.classList.remove(...whenUnchecked)
      this.label.classList.add(...whenChecked)
    } else {
      this.label.classList.remove(...whenChecked)
      this.label.classList.add(...whenUnchecked)
    }

    const whenDisabled = ["opacity-25", "cursor-not-allowed"]
    const whenEnabled = ["cursor-pointer"]
    if (this.checkbox.disabled) {
      this.label.classList.remove(...whenEnabled)
      this.label.classList.add(...whenDisabled)
    } else {
      this.label.classList.remove(...whenDisabled)
      this.label.classList.add(...whenEnabled)
    }
  }
}