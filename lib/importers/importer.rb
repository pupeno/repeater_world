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

class Importer
  USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 https://repeater.world/crawler info@repeater.world"

  include Rails.application.routes.url_helpers

  def initialize(working_directory: nil, logger: nil)
    @working_directory = working_directory || Rails.root.join("tmp", (self.class.name || SecureRandom.alphanumeric).downcase).to_s # Stable working directory to avoid re-downloading when developing.
    @logger = logger || Rails.logger
  end

  def import
    @logger.info "Importing repeaters from #{self.class.source}"
    result = import_data
    @logger.info "Done importing from #{self.class.source}:"
    @logger.info "  #{result[:created_or_updated_ids].count} created or updated"
    @logger.info "  #{result[:ignored_due_to_source_count] || 0} ignored due to source"
    @logger.info "  #{result[:ignored_due_to_invalid_count] || 0} ignored due to being invalid"
    @logger.info "  #{result[:repeaters_deleted_count] || 0} deleted."
  end

  def self.source
    raise NotImplementedError.new("Importer subclasses must implement this method.")
  end

  private

  def import_data
    raise NotImplementedError.new("Importer subclasses must implement this method.")
  end

  def download_file(url, dest)
    dest = File.join(@working_directory, dest)
    if !File.exist?(dest)
      @logger.info "Downloading #{url} to #{dest}"
      dirname = File.dirname(dest)
      FileUtils.mkdir_p(dirname) if !File.directory?(dirname)
      parsed_url = URI.parse(url)
      begin
        attempts ||= 1
        src_stream = parsed_url.open({"User-Agent" => USER_AGENT})
      rescue Net::OpenTimeout => e
        if attempts <= 10
          @logger.warn "Failed to download #{url} to #{dest} on attempt #{attempts}: #{e.message}. Retrying in 5 seconds."
          attempts += 1
          sleep 5
          retry
        else
          raise
        end
      end
      IO.copy_stream(src_stream, dest)
    else
      @logger.info "Skipping download of #{url} because #{dest} already exists."
    end

    dest
  end
end
