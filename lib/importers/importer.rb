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
    raise NotImplementedError.new("Importer subclasses must implement #import")
  end

  private

  def download_file(url, dest)
    dest = File.join(@working_directory, dest)
    if !File.exist?(dest)
      @logger.info "Downloading #{url}"
      dirname = File.dirname(dest)
      FileUtils.mkdir_p(dirname) if !File.directory?(dirname)
      src_stream = URI.parse(url).open({"User-Agent" => USER_AGENT})
      IO.copy_stream(src_stream, dest)
    else
      @logger.info "Skipping download of #{url} because #{dest} already exists."
    end

    dest
  end
end