# Copyright 2023-2024, Pablo Fernandez
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

  [UkrepeatersImporter.new,
   SralfiImporter.new,
   NerepeatersImporter.new,
   WiaImporter.new,
   IrtsImporter.new,
   NarccImporter.new,
   ScrrbaImporter.new,
   IrlpImporter.new, # This enhances other importers, it's better to do it close to the end.
   ArtscipubImporter.new # Should always be the last one.
  ].each do |importer|
    begin
      importer.import
    rescue => e
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace.join("\n"))
      Sentry.capture_exception(e)
    end
  end
end

desc "Import repeaters from https://ukrepeater.net"
task :import_ukrepeaters, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  UkrepeatersImporter.new.import
end

desc "Import repeaters from https://automatic.sral.fi"
task :import_sralfi, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  SralfiImporter.new.import
end

desc "Import repeaters from http://www.nerepeaters.com/"
task :import_nerepeaters, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  NerepeatersImporter.new.import
end

desc "Import repeaters from https://www.wia.org.au"
task :import_wia, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  WiaImporter.new.import
end

desc "Import repeaters from https://www.irlp.net"
task :import_irts, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  IrtsImporter.new.import
end

desc "Import repeaters from https://www.narcconline.org/narcc/repeater_list_menu.cfm"
task :import_narcc, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  NarccImporter.new.import
end

desc "Import repeaters from https://www.scrrba.org"
task :import_scrrba, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  ScrrbaImporter.new.import
end

desc "Import repeaters from http://www.artscipub.com"
task :import_artscipub, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  ArtscipubImporter.new.import
end

desc "Import repeaters from https://www.irlp.net"
task :import_irlp, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  IrlpImporter.new.import
end
