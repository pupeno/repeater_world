desc "Import repeaters from ukrepeaters.net, https://ukrepeater.net/csvfiles.html"
task import_ukrepeaters: :environment do
  UkrepeatersImporter.new.import
end
