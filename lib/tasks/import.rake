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

  begin
    UkrepeatersImporter.new.import
  rescue => e
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end
  begin
    SralfiImporter.new.import
  rescue => e
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end
  begin
    NerepeatersImporter.new.import
  rescue => e
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end
  begin
    WiaImporter.new.import
  rescue => e
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end
  begin
    IrtsImporter.new.import
  rescue => e
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end
  begin
    NarccImporter.new.import
  rescue => e
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end
  begin
    ArtscipubImporter.new.import
  rescue => e
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end

  # Keep it at the bottom, since we don't access code and other sources might have them in better shape
  begin
    IrlpImporter.new.import
  rescue => e
    Rails.logger.error(e.message)
    Sentry.capture_exception(e)
  end
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

desc "Import repeaters from NARCC, https://www.narcconline.org/narcc/repeater_list_menu.cfm"
task :import_narcc, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  NarccImporter.new.import
end

desc "Import repeaters from Artscipub, http://www.artscipub.com/repeaters"
task :import_artscipub, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  ArtscipubImporter.new.import
end

desc "Import repeaters from IRLP, https://www.irlp.net"
task :import_irlp, [:stdout] => :environment do |_t, _args|
  Rails.logger = Logger.new($stdout)
  IrlpImporter.new.import
end
