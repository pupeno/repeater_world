import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rxFreqAsFreq", "rxFreqAsOffset", "locationFormat1", "locationFormat2", "locationFormat3"]

  toggleRxFrequencyFormat() {
    if (this.rxFreqAsFreqTarget.classList.contains("hidden")) {
      this.rxFreqAsFreqTargets.forEach((x) => x.classList.remove("hidden"))
      this.rxFreqAsOffsetTargets.forEach((x) => x.classList.add("hidden"))
    } else {
      this.rxFreqAsFreqTargets.forEach((x) => x.classList.add("hidden"))
      this.rxFreqAsOffsetTargets.forEach((x) => x.classList.remove("hidden"))
    }
  }

  changeLocationFormat() {
    console.log(this.locationFormat1Target.classList.contains("hidden"))
    if (!this.locationFormat1Target.classList.contains("hidden")) {
      this.locationFormat1Targets.forEach((x) => x.classList.add("hidden"))
      this.locationFormat2Targets.forEach((x) => x.classList.remove("hidden"))
      this.locationFormat3Targets.forEach((x) => x.classList.add("hidden"))
    } else if (!this.locationFormat2Target.classList.contains("hidden")) {
      this.locationFormat1Targets.forEach((x) => x.classList.add("hidden"))
      this.locationFormat2Targets.forEach((x) => x.classList.add("hidden"))
      this.locationFormat3Targets.forEach((x) => x.classList.remove("hidden"))
    } else {
      this.locationFormat1Targets.forEach((x) => x.classList.remove("hidden"))
      this.locationFormat2Targets.forEach((x) => x.classList.add("hidden"))
      this.locationFormat3Targets.forEach((x) => x.classList.add("hidden"))
    }
  }
}
