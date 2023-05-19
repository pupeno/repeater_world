/* Copyright 2023, Pablo Fernandez
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
  static targets = ["modalPanel", "backgroundBackdrop"]

  show(event) {
    event.stopImmediatePropagation()
    this.element.classList.remove("hidden")
    enter(this.backgroundBackdropTarget)
    enter(this.modalPanelTarget)
  }

  hide() {
    Promise.all([
      leave(this.backgroundBackdropTarget),
      leave(this.modalPanelTarget)
    ]).then(() => {
      this.element.classList.add("hidden")
    })
  }

  // Stop propagating an event so that clicking on the pop up doesn't close it, but
  // everywhere else, it does.
  dontHide(event) {
    event.stopPropagation()
  }
}
