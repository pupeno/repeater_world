import {Controller} from "@hotwired/stimulus"
import {enter, leave} from "el-transition";


export default class extends Controller {
  static targets = ["signInOrLogInPopUp", "modalPanel"]

  // Turns the get search form into a post save form.
  saveSearch() {
    if (this.element.getAttribute("method") === "get") { // Only act on the get form, not on the patch of the show/edit action.
      this.element.setAttribute("method", "post")
      this.element.setAttribute("action", this.element.getAttribute("data-repeater-searches-url"))

      // Add the csrf hidden input if it's not there yet.
      const csrfParam = document.head.querySelector("meta[name='csrf-param']").content
      if (!this.element.querySelector(`input[name=${csrfParam}]`)) {
        let csrfHidenInput = document.createElement("input")
        csrfHidenInput.setAttribute("type", "hidden")
        csrfHidenInput.setAttribute("autocomplete", "off")
        csrfHidenInput.setAttribute("name", csrfParam)
        csrfHidenInput.setAttribute("value", document.head.querySelector("meta[name='csrf-token']").content)
        this.element.appendChild(csrfHidenInput)
      }
    }
  }

  askToSignInOrLogIn(event) {
    event.preventDefault()
    showPopUp(this.signInOrLogInPopUpTarget)
  }
}


function showPopUp(popUp) {
  this.dispatch("show", {target: popUp, prefix: "popUp", bubbles: false, cancelable: true})
}
