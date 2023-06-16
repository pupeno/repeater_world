# Copyright 2023, Flexpoint Tech
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Repeater World is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
# <https://www.gnu.org/licenses/>.

desc "Import repeaters from all sources"
task :import_all, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  UkrepeatersImporter.new.import
  SralfiImporter.new.import
  NerepeatersImporter.new.import
  WiaImporter.new.import
  IrtsImporter.new.import
  RepeaterGeocoder.new.geocode
end

desc "Import repeaters from ukrepeaters.net, https://ukrepeater.net/csvfiles.html"
task :import_ukrepeaters, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  UkrepeatersImporter.new.import
end

desc "Import repeaters from automatic.sral.fi, https://automatic.sral.fi/api-v1.php?query=list"
task :import_sralfi, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  SralfiImporter.new.import
end

desc "Import repeaters from nerepeaters.com, http://www.nerepeaters.com"
task :import_nerepeaters, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  NerepeatersImporter.new.import
end

desc "Import repeaters from WIA, https://www.wia.org.au"
task :import_wia, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  WiaImporter.new.import
end

desc "Import repeaters from IRTS, https://www.irts.ie"
task :import_irts, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  IrtsImporter.new.import
end

desc "Geocode all non-geocoded repeaters"
task :geocode_repeaters, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  RepeaterGeocoder.new.geocode
end
