desc "Import repeaters from ukrepeaters.net, https://ukrepeater.net/csvfiles.html"
task :import_ukrepeaters, [:stdout] => :environment do |t, args|
  if args[:stdout] == "true"
    Rails.logger = Logger.new($stdout)
  end
  UkrepeatersImporter.new.import
end
