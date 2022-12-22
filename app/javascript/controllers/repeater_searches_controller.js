import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  saveSearch(event) {
    // Turn the form into a save form... and let the submit event continue.
    this.element.setAttribute("method", "post")
    this.element.setAttribute("action", this.element.getAttribute("data-repeater-searches-url"))
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
