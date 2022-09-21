desc "Ingest repeaters from ukrepeaters, https://ukrepeater.net/csvfiles.html"
task ingest_ukrepeaters: :environment do
  UkrepeatersImporter.new.import
end
