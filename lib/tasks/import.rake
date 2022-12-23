desc "Import repeaters from ukrepeaters.net, https://ukrepeater.net/csvfiles.html"
task :import_ukrepeaters, [:stdout] => :environment do |t, args|
  Rails.logger = Logger.new($stdout)
  UkrepeatersImporter.new.import
end
