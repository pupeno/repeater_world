import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.checkbox = this.element.querySelectorAll('input[type=checkbox]')[0];
    this.label = this.element.querySelectorAll('label')[0];

    this.checkbox.addEventListener("change", this.updateBadge.bind(this));

    this.updateBadge()
    this.label.classList.remove("bg-gray-200", "text-gray-800")
  }

  disconnect() {
    this.checkbox.removeEventListener("change", this.updateBadge.bind(this));
  }

  updateBadge() {
    const whenChecked = ["bg-orange-800", "text-orange-200"];
    const whenUnchecked = ["bg-orange-200", "text-orange-800"];
    if (this.checkbox.checked) {
     this.label.classList.add(...whenChecked);
     this.label.classList.remove(...whenUnchecked);
    } else {
      this.label.classList.add(...whenUnchecked);
      this.label.classList.remove(...whenChecked);
    }
  }
}
