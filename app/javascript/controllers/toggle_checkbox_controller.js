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
    this.checkbox = this.element.querySelector("input[type=checkbox]")
    this.label = this.element.querySelector("label")
    this.slot = this.label.querySelector("span.slot")
    this.circle = this.label.querySelector("span.circle")

    this.checkbox.addEventListener("change", this.updateBadge.bind(this))

    this.updateBadge()
    this.slot.classList.remove("bg-gray-200")
    this.circle.classList.remove("translate-x-2.5")
  }

  disconnect() {
    this.checkbox.removeEventListener("change", this.updateBadge.bind(this))
  }

  updateBadge() {
    const orangeBackground = "bg-orange-800"
    const grayBackground = "bg-orange-300"
    const animateRight = "translate-x-5"
    const animateLeft = "translate-x-0"
    if (this.checkbox.checked) {
      this.slot.classList.add(orangeBackground)
      this.slot.classList.remove(grayBackground)
      this.circle.classList.add(animateRight)
      this.circle.classList.remove(animateLeft)
    } else {
      this.slot.classList.add(grayBackground)
      this.slot.classList.remove(orangeBackground)
      this.circle.classList.add(animateLeft)
      this.circle.classList.remove(animateRight)
    }
  }
}
