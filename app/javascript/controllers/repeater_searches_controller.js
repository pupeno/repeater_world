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
  static targets = ["form", "authPopUp", "exportPopUp", "modalPanel", "exportLink"]

  exportLinkTargetConnected(target) {
    target.click()
    let url = new URL(location.href)
    url.searchParams.delete("export")
    history.replaceState(history.state, null, url.toString())
  }

  // Turns the get search form into a post save form.
  saveSearch() {
    if (this.formTarget.getAttribute("method") === "get") { // Only act on the get form, not on the patch of the show/edit action.
      this.formTarget.setAttribute("method", "post")
      this.formTarget.setAttribute("action", this.formTarget.getAttribute("data-repeater-searches-url"))

      // Add the csrf hidden input if it's not there yet.
      const csrfParam = document.head.querySelector("meta[name='csrf-param']").content
      if (!this.formTarget.querySelector(`input[name=${csrfParam}]`)) {
        let csrfHidenInput = document.createElement("input")
        csrfHidenInput.setAttribute("type", "hidden")
        csrfHidenInput.setAttribute("autocomplete", "off")
        csrfHidenInput.setAttribute("name", csrfParam)
        csrfHidenInput.setAttribute("value", document.head.querySelector("meta[name='csrf-token']").content)
        this.formTarget.appendChild(csrfHidenInput)
      }
    }
  }

  showAuthPopUp() {
    this.showPopUp(this.authPopUpTarget)
  }

  showExportPopUp() {
    this.showPopUp(this.exportPopUpTarget)
  }

  export() {
    let exportHidenInput = document.createElement("input")
    exportHidenInput.setAttribute("type", "hidden")
    exportHidenInput.setAttribute("autocomplete", "off")
    exportHidenInput.setAttribute("name", "export")
    exportHidenInput.setAttribute("value", "true")
    this.formTarget.appendChild(exportHidenInput)
  }

  showPopUp(popUp) {
    this.dispatch("show", {target: popUp, prefix: "pop-up"})
  }
}
