import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.checkbox = this.element.querySelector("input[type=checkbox]");
    this.label = this.element.querySelector("label");
    this.slot = this.label.querySelector("span.slot");
    this.circle = this.label.querySelector("span.circle");

    this.checkbox.addEventListener("change", this.updateBadge.bind(this));

    this.updateBadge()
    this.slot.classList.remove("bg-orange-400")
    this.circle.classList.remove("translate-x-2.5")
  }

  disconnect() {
    this.checkbox.removeEventListener("change", this.updateBadge.bind(this));
  }

  updateBadge() {
    const orangeBackground = "bg-orange-800";
    const grayBackground = "bg-orange-200";
    const animateRight = "translate-x-5";
    const animateLeft = "translate-x-0";
    if (this.checkbox.checked) {
      this.slot.classList.add(orangeBackground)
      this.slot.classList.remove(grayBackground)
      this.circle.classList.add(animateRight)
      this.circle.classList.remove(animateLeft)
    } else {
      this.slot.classList.add(grayBackground)
      this.slot.classList.remove(orangeBackground)
      this.circle.classList.add(animateLeft)
      this.circle.classList.remove(animateRight)
    }
  }
}
