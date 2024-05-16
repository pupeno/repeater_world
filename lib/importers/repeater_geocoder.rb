# Copyright 2023, Pablo Fernandez
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Repeater World is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
# <https://www.gnu.org/licenses/>.

class RepeaterGeocoder
  def geocode
    Rails.logger.info "Geocoding all repeaters that need it."
    repeater_count = Repeater.count
    Rails.logger.info "There are #{repeater_count} repeaters in the database."

    # Collect all repeaters that need geocoding.
    repeaters = Repeater.where(
      "(address IS NOT NULL OR
        locality IS NOT NULL OR
        region IS NOT NULL OR
        post_code IS NOT NULL) AND
       (location IS NULL OR
        ST_DWithin(location, :point, :distance) OR
        (geocoded_at IS NOT NULL AND geocoded_at < :geocoded_at) OR
        (address != geocoded_address OR
         locality != geocoded_locality OR
         region != geocoded_region OR
         post_code != geocoded_post_code OR
         country_id != geocoded_country_id))",
      {point: Geo.to_wkt(Geo.point(0, 0)),
       distance: 0.1,
       geocoded_at: 1.year.ago}
    ).includes(:country)

    repeaters_to_geocode_count = repeaters.count
    Rails.logger.info "There are #{repeaters_to_geocode_count} repeaters to be geocoded."

    geocoded_repeater_count = 0
    repeaters.each do |repeater|
      geocode = Geocoder.search(RepeaterUtils.location_in_words(repeater)).first
      if geocode.present?
        repeater.latitude = geocode.latitude
        repeater.longitude = geocode.longitude
        repeater.geocoded_at = Time.now
        repeater.geocoded_by = geocode.class.name
        repeater.geocoded_address = repeater.address
        repeater.geocoded_locality = repeater.locality
        repeater.geocoded_region = repeater.region
        repeater.geocoded_post_code = repeater.post_code
        repeater.geocoded_country_id = repeater.country_id
        repeater.save!
        Rails.logger.info "Geocoded #{repeater}."
        geocoded_repeater_count += 1
      end
    end

    Rails.logger.info "Done geocoding repeaters."
    {geocoded_repeater_count: geocoded_repeater_count,
     repeaters_to_geocode_count: repeaters_to_geocode_count,
     repeater_count: repeater_count}
  end
end
