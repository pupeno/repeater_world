import {Controller} from "@hotwired/stimulus"
import {enter, leave} from "el-transition";

export default class extends Controller {
  static targets = ["modalPanel", "backgroundBackdrop"]

  show(event) {
    event.stopImmediatePropagation()
    this.element.classList.remove("hidden")
    enter(this.backgroundBackdropTarget)
    enter(this.modalPanelTarget)
  }

  hide() {
    Promise.all([
      leave(this.backgroundBackdropTarget),
      leave(this.modalPanelTarget)
    ]).then(() => {
      this.element.classList.add("hidden")
    })
  }
}
