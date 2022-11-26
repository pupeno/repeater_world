import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.checkbox = this.element.querySelectorAll('input[type=checkbox]')[0];
    this.label = this.element.querySelectorAll('label')[0];

    this.checkbox.addEventListener("change", this.updateBadge.bind(this));

    this.updateBadge()
  }

  disconnect() {
    this.checkbox.removeEventListener("change", this.updateBadge.bind(this));
  }

  updateBadge() {
    if (this.checkbox.checked) {
      this.label.querySelectorAll("span")[2].classList.add("bg-indigo-600")
      this.label.querySelectorAll("span")[2].classList.remove("bg-gray-200")
      this.label.querySelectorAll("span")[3].classList.add("translate-x-5")
      this.label.querySelectorAll("span")[3].classList.remove("translate-x-0")
    } else {
      this.label.querySelectorAll("span")[2].classList.add("bg-gray-200")
      this.label.querySelectorAll("span")[2].classList.remove("bg-indigo-600")
      this.label.querySelectorAll("span")[3].classList.add("translate-x-0")
      this.label.querySelectorAll("span")[3].classList.remove("translate-x-5")
    }
  }
}
