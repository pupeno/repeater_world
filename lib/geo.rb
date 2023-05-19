# Copyright 2023, Flexpoint Tech
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

# This comes from https://pganalyze.com/blog/postgis-rails-geocoder
class Geo
  SRID = 4326

  def self.factory
    @@factory ||= RGeo::Geographic.spherical_factory(srid: SRID)
  end

  # TODO: not used yet.
  # def self.pairs_to_points(pairs)
  #   pairs.map { |pair| point(pair[0], pair[1]) }
  # end

  def self.point(latitude, longitude)
    # The reason why latitude and longitude get inverted seems to be because PastGIS is
    # working in x and y coordinates of a point, and x is latitude, and y is longitude,
    # so x and y is longitude and latitude, in that order. But this module is for
    # working with geographic coordinates, so it extracts a latitude, longitude
    # interface.
    factory.point(longitude, latitude)
  end

  # TODO: not used yet
  # def self.line_string(points)
  #   factory.line_string(points)
  # end

  # TODO: not used yet
  # def self.polygon(points)
  #   line = line_string(points)
  #   factory.polygon(line)
  # end

  def self.to_wkt(feature)
    "srid=#{SRID};#{feature}"
  end
end
