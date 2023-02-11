import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    markers: Array
  }

  connect() {
    if (typeof (google) != "undefined"){
      this.initializeMap()
    }
  }

  initializeMap() {
    let map = new google.maps.Map(this.element, {
      center: {lat: 51.5, lng: 0},
      zoom: 8,
    });

    this.markersValue.forEach(marker => {
      const infowindow = new google.maps.InfoWindow({
        content: marker.info,
        ariaLabel: "label",
      });
      const mapMarker = new google.maps.Marker({
        position: {lat: marker.lat, lng: marker.lng},
        map,
        title: marker.tooltip,
        //icon: "<%= image_url "font-awesome/tower-cell-solid.svg" %>"
      })
      mapMarker.addListener("click", () => {
        infowindow.open({
          anchor: mapMarker,
          map,
        });
      });
    })
  }
}
