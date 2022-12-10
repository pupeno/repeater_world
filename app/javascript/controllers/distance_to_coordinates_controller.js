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
    const grayedOutText = "text-gray-400";
    if (this.controllerTarget.checked) {
      this.controlledTargets.forEach(x => x.classList.remove(grayedOutText))
    } else {
      this.controlledTargets.forEach(x => x.classList.add(grayedOutText))
    }
  }
}
