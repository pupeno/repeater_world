desc "Export repeaters to CSV"
task export: :environment do
  # TODO: allow the command line to select the exporter.

  exporter = IcomId52Exporter.new(Repeater.all)

  puts exporter.export
end
