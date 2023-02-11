import {Controller} from "@hotwired/stimulus"
import { MarkerClusterer } from "@googlemaps/markerclusterer";


export default class extends Controller {
  static values = {
    markers: Array
  }

  connect() {
    if (typeof (google) != "undefined") {
      this.initializeMap()
    }
  }

  initializeMap() {
    let map = new google.maps.Map(this.element, {center: {lat: 0, lng: 0}, zoom: 2});

    let bounds = new google.maps.LatLngBounds();

    const markers = this.markersValue.map(marker => {
      let isInfoWindowOpen = false;
      const infoWindow = new google.maps.InfoWindow({
        content: marker.info,
        ariaLabel: "label",
      });
      const mapMarker = new google.maps.Marker({
        position: {lat: marker.lat, lng: marker.lng},
        title: marker.tooltip,
      })
      mapMarker.addListener("click", () => {
        if (isInfoWindowOpen) {
          infoWindow.close()
        } else {
          infoWindow.open({anchor: mapMarker, map});
        }
        isInfoWindowOpen = !isInfoWindowOpen;
      });
      bounds.extend(new google.maps.LatLng(marker.lat, marker.lng))

      return mapMarker;
    })

    new MarkerClusterer({ markers, map });
    map.fitBounds(bounds);
  }
}
