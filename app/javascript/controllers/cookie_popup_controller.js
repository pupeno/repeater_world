import {Controller} from "@hotwired/stimulus"
import Cookies from "js-cookie"

export default class extends Controller {
  connect() {
    if (!Cookies.get("accept-cookies")) {
      this.element.classList.remove("hidden")
    }
  }

  acceptCookies() {
    Cookies.set("accept-cookies", true)
    this.element.classList.add("hidden")
  }
}
