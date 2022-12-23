import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["flashMessage"]

  close() {
    this.flashMessageTarget.classList.add("hidden")
  }
}
