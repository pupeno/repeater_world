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

export const WHEN_CHECKED = "button-toggle-checked"

export const WHEN_UNCHECKED = "button-toggle-unchecked"

export default class extends Controller {
  connect() {
    this.checkbox = this.element.querySelectorAll('input[type=checkbox]')[0]
    this.label = this.element
    this.updateStyle()
  }

  updateStyle() {
    if (this.checkbox.checked) {
      this.label.classList.remove(WHEN_UNCHECKED)
      this.label.classList.add(WHEN_CHECKED)
    } else {
      this.label.classList.remove(WHEN_CHECKED)
      this.label.classList.add(WHEN_UNCHECKED)
    }
  }
}
