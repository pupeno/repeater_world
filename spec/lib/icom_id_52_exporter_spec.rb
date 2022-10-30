require "rails_helper"

RSpec.describe IcomId52Exporter do
  it "should export" do
    repeaters = 10.times.collect { create(:repeater) }

    exporter = IcomId52Exporter.new(Repeater.all)

    export = exporter.export
    puts export

  end
end
