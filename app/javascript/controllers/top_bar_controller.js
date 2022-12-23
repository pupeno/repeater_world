import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "desktopUserMenu", "desktopUserMenuButton",
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
    if (this.isDesktopUserMenuOpen()) {
      this.closeDesktopUserMenu()
    }
  }

  toggleDesktopUserMenu(event) {
    event.stopImmediatePropagation()
    if (this.isDesktopUserMenuOpen()) {
      this.closeDesktopUserMenu()
    } else {
      this.openDesktopUserMenu()
    }
  }

  isDesktopUserMenuOpen() {
    return this.hasDesktopUserMenuTarget && !this.desktopUserMenuTarget.classList.contains("hidden");
  }

  closeDesktopUserMenu() {
    // Button state.
    this.desktopUserMenuButtonTarget.setAttribute("aria-expanded", false)

    // Actual menu.
    this.desktopUserMenuTarget.classList.add("hidden")
  }

  openDesktopUserMenu() {
    // Button state.
    this.desktopUserMenuButtonTarget.setAttribute("aria-expanded", true)

    // Actual menu.
    this.desktopUserMenuTarget.classList.remove("hidden")
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
    return this.mobileOpenMenuButtonTarget.classList.contains("hidden");
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
