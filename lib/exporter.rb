class Exporter
  def initialize(repeaters)
    @repeaters = repeaters
  end

  def export
    raise NotImplementedError.new("Method should be implemented in subclass.")
  end
end
