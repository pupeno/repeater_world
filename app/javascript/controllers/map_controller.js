import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (typeof (google) != "undefined"){
      this.initializeMap()
    }
  }

  initializeMap() {
    let map = new google.maps.Map(this.element, {
      center: {lat: -34.397, lng: 150.644},
      zoom: 8,
    });

    const infowindow = new google.maps.InfoWindow({
      content: "string",
      ariaLabel: "label",
    });
    const marker = new google.maps.Marker({
      position: {lat: -34.397, lng: 150.644},
      map,
      title: "Hey!",
      //icon: "<%= image_url "font-awesome/tower-cell-solid.svg" %>"
    })
    marker.addListener("click", () => {
      infowindow.open({
        anchor: marker,
        map,
      });
    });
  }
}
