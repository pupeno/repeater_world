import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  switch(event) {
    window.location.href = event.target.value
  }
}
