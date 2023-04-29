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
  static targets = ["controller", "controlled"]

  connect() {
    this.controllerTarget.addEventListener("change", this.toggleDisable.bind(this));

    this.toggleDisable();
  }

  disconnect() {
    this.controllerTarget.removeEventListener("change", this.toggleDisable.bind(this));
  }

  toggleDisable() {
    const grayedOutText = "text-gray-300";
    if (this.controllerTarget.checked) {
      this.controlledTargets.forEach(x => x.classList.remove(grayedOutText))
    } else {
      this.controlledTargets.forEach(x => x.classList.add(grayedOutText))
    }
  }
}
