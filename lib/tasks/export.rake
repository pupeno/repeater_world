require "optparse"

desc "Export repeaters to CSV"
task :export, [:exporter] => :environment do |t, args|
  if args[:exporter].blank?
    raise "Exporter needs to be specified"
  end

  exporter = Object.const_get("#{args[:exporter]}Exporter").new(Repeater.all)

  puts exporter.export
end
