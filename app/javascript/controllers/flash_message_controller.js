import { Controller } from "@hotwired/stimulus"


console.log("flash message")

export default class extends Controller {
  static targets = ["flashMessage"]

  close() {
    this.flashMessageTarget.classList.add("hidden")
  }
}
