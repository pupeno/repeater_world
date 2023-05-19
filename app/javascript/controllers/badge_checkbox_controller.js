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
 * You should have received a copy of the GNU Affero General Public License along with Foobar. If not, see
 * <https://www.gnu.org/licenses/>.
 */

import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.checkbox = this.element.querySelectorAll('input[type=checkbox]')[0]
    this.label = this.element.querySelectorAll('label')[0]

    this.checkbox.addEventListener("change", this.updateBadge.bind(this))

    this.updateBadge()
    this.label.classList.remove("bg-gray-200", "text-gray-800")
  }

  disconnect() {
    this.checkbox.removeEventListener("change", this.updateBadge.bind(this))
  }

  updateBadge() {
    const whenChecked = ["bg-orange-800", "text-orange-300"]
    const whenUnchecked = ["bg-orange-300", "text-orange-800"]
    if (this.checkbox.checked) {
      this.label.classList.add(...whenChecked)
      this.label.classList.remove(...whenUnchecked)
    } else {
      this.label.classList.add(...whenUnchecked)
      this.label.classList.remove(...whenChecked)
    }
  }
}
