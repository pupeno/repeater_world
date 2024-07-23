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

class Importer
  USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 https://repeater.world/crawler info@repeater.world"

  include Rails.application.routes.url_helpers

  def initialize(working_directory: nil, logger: nil)
    @working_directory = working_directory || Rails.root.join("tmp", (self.class.name || SecureRandom.alphanumeric).downcase).to_s # Stable working directory to avoid re-downloading when developing.
    @logger = logger || Rails.logger
    PaperTrail.request.whodunnit = "Repeater World Importer"
  end

  def import
    @logger.info "Importing repeaters from #{self.class.source}"
    result = import_data
    @logger.info "Done importing from #{self.class.source}:"
    @logger.info "  #{result[:created_or_updated_ids].count} created or updated"
    @logger.info "  #{result[:ignored_due_to_source_count] || 0} ignored due to source"
    @logger.info "  #{result[:ignored_due_to_invalid_count] || 0} ignored due to being invalid"
    @logger.info "  #{result[:repeaters_deleted_count] || 0} deleted"
  end

  def self.source
    raise NotImplementedError.new("Importer subclasses must implement this method.")
  end

  def figure_out_us_state(state)
    state = state.downcase
    if state.in? ["al", "alabama"]
      "Alabama"
    elsif state.in? ["ak", "alaska"]
      "Alaska"
    elsif state.in? ["az", "arizona"]
      "Arizona"
    elsif state.in? ["ar", "arkansas"]
      "Arkansas"
    elsif state.in? ["ca", "california"]
      "California"
    elsif state.in? ["co", "colorado"]
      "Colorado"
    elsif state.in? ["ct", "connecticut"]
      "Connecticut"
    elsif state.in? ["de", "delaware"]
      "Delaware"
    elsif state.in? ["fl", "florida"]
      "Florida"
    elsif state.in? ["ga", "georgia"]
      "Georgia"
    elsif state.in? ["hi", "hawaii"]
      "Hawaii"
    elsif state.in? ["id", "idaho"]
      "Idaho"
    elsif state.in? ["il", "illinois"]
      "Illinois"
    elsif state.in? ["in", "indiana"]
      "Indiana"
    elsif state.in? ["ia", "iowa"]
      "Iowa"
    elsif state.in? ["ks", "kansas"]
      "Kansas"
    elsif state.in? ["ky", "kentucky"]
      "Kentucky"
    elsif state.in? ["la", "louisiana"]
      "Louisiana"
    elsif state.in? ["me", "maine"]
      "Maine"
    elsif state.in? ["md", "maryland"]
      "Maryland"
    elsif state.in? ["ma", "massachusetts"]
      "Massachusetts"
    elsif state.in? ["mi", "michigan"]
      "Michigan"
    elsif state.in? ["mn", "minnesota"]
      "Minnesota"
    elsif state.in? ["ms", "mississippi"]
      "Mississippi"
    elsif state.in? ["mo", "missouri"]
      "Missouri"
    elsif state.in? ["mt", "montana"]
      "Montana"
    elsif state.in? ["ne", "nebraska"]
      "Nebraska"
    elsif state.in? ["nv", "nevada"]
      "Nevada"
    elsif state.in? ["nh", "new hampshire"]
      "New Hampshire"
    elsif state.in? ["nj", "new jersey"]
      "New Jersey"
    elsif state.in? ["nm", "new mexico"]
      "New Mexico"
    elsif state.in? ["ny", "new york"]
      "New York"
    elsif state.in? ["nc", "north carolina"]
      "North Carolina"
    elsif state.in? ["nd", "north dakota"]
      "North Dakota"
    elsif state.in? ["oh", "ohio"]
      "Ohio"
    elsif state.in? ["ok", "oklahoma"]
      "Oklahoma"
    elsif state.in? ["or", "oregon"]
      "Oregon"
    elsif state.in? ["pa", "pennsylvania"]
      "Pennsylvania"
    elsif state.in? ["ri", "rhode island"]
      "Rhode Island"
    elsif state.in? ["sc", "south carolina"]
      "South Carolina"
    elsif state.in? ["sd", "south dakota"]
      "South Dakota"
    elsif state.in? ["tn", "tennessee"]
      "Tennessee"
    elsif state.in? ["tx", "texas"]
      "Texas"
    elsif state.in? ["ut", "utah"]
      "Utah"
    elsif state.in? ["vt", "vermont"]
      "Vermont"
    elsif state.in? ["va", "virginia"]
      "Virginia"
    elsif state.in? ["wa", "washington"]
      "Washington"
    elsif state.in? ["wv", "west virginia"]
      "West Virginia"
    elsif state.in? ["wi", "wisconsin"]
      "Wisconsin"
    elsif state.in? ["wy", "wyoming"]
      "Wyoming"
    elsif state.in? ["vi"]
      "US Virgin Islands"
    elsif state.in? ["puerto rico"]
      "Puerto Rico"
    elsif state.in? ["dc", "district of columbia", "na"]
      nil
    else
      raise "Invalid US state: #{state}"
    end
  end

  def figure_out_canadian_province(province)
    province = province.downcase

    if province.in? ["ab", ".canada-alberta"]
      "Alberta"
    elsif province.in? ["bc", ".canada-british columbia"]
      "British Columbia"
    elsif province.in? ["mb", ".canada-manitoba"]
      "Manitoba"
    elsif province.in? ["nl", ".canada-newfoundland"]
      "Newfoundland"
    elsif province.in? ["nt", ".canada-northwest territories"]
      "Northwest Territories"
    elsif province.in? ["ns", ".canada-nova scotia"]
      "Nova Scotia"
    elsif province.in? ["nu", ".canada-nunavut"]
      "Nunavut"
    elsif province.in? ["on", ".canada-ontario"]
      "Ontario"
    elsif province.in? ["qc", ".canada-quebec"]
      "Quebec"
    elsif province.in? ["sk", ".canada-saskatchewan"]
      "Saskatchewan"
    elsif province.in? ["pe"]
      "Prince Edward Island	"
    elsif province.in? ["yt"]
      "Yukon"
    else
      raise "Unknown Canadian province: #{province}"
    end
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
      rescue Net::OpenTimeout, OpenURI::HTTPError => e
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
