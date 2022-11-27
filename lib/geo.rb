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

  def self.point(longitude, latitude)
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
