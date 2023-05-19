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
import {enter, leave} from "el-transition"

export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    document.addEventListener("click", this.handleClickOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside.bind(this))
  }

  handleClickOutside() {
    if (this.isOpen()) {
      this.close()
    }
  }

  isOpen() {
    return !this.menuTarget.classList.contains("hidden")
  }

  open() {
    // Button state
    this.buttonTarget.setAttribute("aria-expanded", true)

    // Menu state
    this.menuTarget.classList.remove("hidden")
    enter(this.menuTarget)
  }

  close() {
    // Button state
    this.buttonTarget.setAttribute("aria-expanded", false)

    // Menu state
    leave(this.menuTarget).then(() => {
      this.menuTarget.classList.add("hidden")
    })
  }

  toggle(event) {
    event.stopImmediatePropagation()
    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }
}
