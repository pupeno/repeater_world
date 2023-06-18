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

const GRAYED_OUT_TEXT = "text-gray-300"
const NORMAL_TEXT = "text-gray-900"

export default class extends Controller {
  static targets = ["activator", "controlled"]

  connect() {
    this.toggleEnableDisable()
  }

  toggleEnableDisable() {
    if (this.activatorTarget.checked) {
      this.enable()
    } else {
      this.disable()
    }
  }

  enable() {
    this.controlledTargets.forEach(element => {
      element.classList.remove(GRAYED_OUT_TEXT)
      element.classList.add(NORMAL_TEXT)
    })
    if (!this.activatorTarget.checked) {
      this.activatorTarget.checked = true
      this.activatorTarget.dispatchEvent(new Event("change"))
    }
  }

  disable() {
    this.controlledTargets.forEach(element => {
      element.classList.remove(NORMAL_TEXT)
      element.classList.add(GRAYED_OUT_TEXT)
    })
  }
}
