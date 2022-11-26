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
    const whenChecked = ["bg-orange-800", "text-orange-100"];
    const whenUnchecked = ["bg-orange-100", "text-orange-800"];
    if (this.checkbox.checked) {
     this.label.classList.add(...whenChecked);
     this.label.classList.remove(...whenUnchecked);
    } else {
      this.label.classList.add(...whenUnchecked);
      this.label.classList.remove(...whenChecked);
    }
  }
}
