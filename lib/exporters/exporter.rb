class Exporter
  def initialize(repeaters)
    @repeaters = repeaters
  end

  def export
    raise NotImplementedError.new("Method should be implemented in subclass.")
  end

  protected

  # Returns the conventional DStar port.
  def conventional_dstar_port(band, country_code)
    if country_code == "jp"
      if band == Repeater::BAND_23CM
        "B"
      elsif band == Repeater::BAND_70CM
        "A"
      else
        raise "Unexpected band #{band} in Japan"
      end
    elsif band == Repeater::BAND_23CM
      "A"
    elsif band == Repeater::BAND_70CM
      "B"
    elsif band == Repeater::BAND_2M
      "C"
    else
      raise "Unexpected band #{band}"
    end
  end

  # Adds the port according to D-Star to a call sign. The port should always be the 8th character and the call sign
  # should be blank space padded accordingly. See page 5-32 of the Icom ID-52 Advanced Manual.
  # TODO:
  def add_dstar_port(call_sign, port)
    "#{call_sign.ljust(6)} #{port}"
  end
end
