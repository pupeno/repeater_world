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
  static targets = [
    "desktopExtraMenu", "desktopExtraMenuButton",
    "mobileMenu", "mobileMenuButton", "mobileOpenMenuButton", "mobileCloseMenuButton"
  ]

  connect() {
    document.addEventListener("click", this.handleClickOutside.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside.bind(this))
  }

  handleClickOutside() {
    if (this.isMobileMenuOpen()) {
      this.closeMobileMenu()
    }
    if (this.isDesktopExtraMenuOpen()) {
      this.closeDesktopExtraMenu()
    }
  }

  toggleDesktopExtraMenu(event) {
    event.stopImmediatePropagation()
    if (this.isDesktopExtraMenuOpen()) {
      this.closeDesktopExtraMenu()
    } else {
      this.openDesktopExtraMenu()
    }
  }

  isDesktopExtraMenuOpen() {
    return this.hasDesktopExtraMenuTarget && !this.desktopExtraMenuTarget.classList.contains("hidden")
  }

  closeDesktopExtraMenu() {
    // Button state.
    this.desktopExtraMenuButtonTarget.setAttribute("aria-expanded", false)

    // Actual menu.
    this.desktopExtraMenuTarget.classList.add("hidden")
  }

  openDesktopExtraMenu() {
    // Button state.
    this.desktopExtraMenuButtonTarget.setAttribute("aria-expanded", true)

    // Actual menu.
    this.desktopExtraMenuTarget.classList.remove("hidden")
  }

  toggleMobileMenu(event) {
    event.stopImmediatePropagation()
    if (this.isMobileMenuOpen()) {
      this.closeMobileMenu()
    } else {
      this.openMobileMenu()
    }
  }

  isMobileMenuOpen() {
    return this.mobileOpenMenuButtonTarget.classList.contains("hidden")
  }

  closeMobileMenu() {
    // Button state.
    this.mobileCloseMenuButtonTarget.classList.add("hidden")
    this.mobileOpenMenuButtonTarget.classList.remove("hidden")
    this.mobileMenuButtonTarget.setAttribute("aria-expanded", false)

    // Actual menu.
    this.mobileMenuTarget.classList.add("hidden")
  }

  openMobileMenu() {
    // Button state.
    this.mobileCloseMenuButtonTarget.classList.remove("hidden")
    this.mobileOpenMenuButtonTarget.classList.add("hidden")
    this.mobileMenuButtonTarget.setAttribute("aria-expanded", true)

    // Actual menu.
    this.mobileMenuTarget.classList.remove("hidden")
  }
}
