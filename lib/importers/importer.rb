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
    @working_directory = if working_directory.present?
      working_directory
    else
      Rails.root.join("tmp", "importer", (self.class.name || SecureRandom.alphanumeric).underscore + "_data").to_s # Stable working directory to avoid re-downloading when developing.
    end
    @logger = logger || Rails.logger
    @created_or_updated_ids = []
    @created_repeaters_count = 0
    @updated_repeaters_count = 0
    @ignored_due_to_source_count = 0
    @ignored_due_to_invalid_count = 0
    @repeaters_deleted_count = 0
    PaperTrail.request.whodunnit = "Repeater World Importer"
  end

  def self.source
    raise NotImplementedError.new("Importer subclasses must implement this method")
  end

  def import
    @logger.info "Importing repeaters from #{self.class.source}"

    import_all_repeaters do |raw_repeater, record_number|
      call_sign, tx_frequency = call_sign_and_tx_frequency(raw_repeater)
      if call_sign.blank? || tx_frequency.blank?
        next
      end
      repeater = Repeater.find_or_initialize_by(call_sign: call_sign, tx_frequency: tx_frequency)
      if should_import?(repeater)
        about_to_create = !repeater.persisted?
        imported_repeater = import_repeater(raw_repeater, repeater)
        if imported_repeater.present?
          @created_or_updated_ids << imported_repeater.id
          @created_repeaters_count += 1 if about_to_create
          @updated_repeaters_count += 1 if !about_to_create
        end
      else
        @ignored_due_to_source_count += 1
      end
    rescue => e
      @logger.error "Failed to import record \"#{record_number}\" with message \n> #{e.message}\nand raw repeater:\n#{raw_repeater}"
      raise
    end
    @repeaters_deleted_count = Repeater.where(source: self.class.source).where.not(id: @created_or_updated_ids).destroy_all.count

    @logger.info "Done importing from #{self.class.source}:"
    @logger.info "  #{@created_repeaters_count} created repeaters"
    @logger.info "  #{@updated_repeaters_count} updated repeaters"
    @logger.info "  #{@ignored_due_to_source_count} ignored repeaters due to source"
    @logger.info "  #{@ignored_due_to_invalid_count} ignored repeaters due to being invalid"
    @logger.info "  #{@repeaters_deleted_count} repeaters deleted"
  end

  private

  def import_all_repeaters
    raise NotImplementedError.new("Importer subclasses must implement this method")
  end

  def call_sign_and_tx_frequency(raw_repeater)
    raise NotImplementedError.new("Importer subclasses must implement this method")
  end

  def import_repeater(raw_repeater, repeater)
    raise NotImplementedError.new("Importer subclasses must implement this method")
  end

  def should_import?(repeater)
    if repeater.new_record? # New repeater, we should import it.
      return true
    end
    if repeater.source == self.class.source # The existing repeater matches the current source.
      return true
    end
    # The repeater was originally imported by Artscipub, so other importers can import it and take over.
    if repeater.source == ArtscipubImporter.source
      return true
    end
    # The repeater was originally imported by IRLP, so other importers can import it and take over.
    if repeater.source == IrlpImporter.source
      return true
    end
    # We always import IrlpImporter, so it keeps the Irlp node number up to date (but other fields are ignored).
    if self.class.source == IrlpImporter.source
      return true
    end
    false
  end

  def figure_out_us_state(state)
    state = state.downcase
    state = if state.in? ["al", "alabama"]
      "AL"
    elsif state.in? ["ak", "alaska"]
      "AK"
    elsif state.in? ["az", "arizona"]
      "AZ"
    elsif state.in? ["ar", "arkansas"]
      "AR"
    elsif state.in? ["ca", "california"]
      "CA"
    elsif state.in? ["co", "colorado"]
      "CO"
    elsif state.in? ["ct", "connecticut"]
      "CT"
    elsif state.in? ["de", "delaware"]
      "DE"
    elsif state.in? ["fl", "florida"]
      "FL"
    elsif state.in? ["ga", "georgia"]
      "GA"
    elsif state.in? ["hi", "hawaii"]
      "HI"
    elsif state.in? ["id", "idaho"]
      "ID"
    elsif state.in? ["il", "illinois"]
      "IL"
    elsif state.in? ["in", "indiana"]
      "IN"
    elsif state.in? ["ia", "iowa"]
      "IA"
    elsif state.in? ["ks", "kansas"]
      "KS"
    elsif state.in? ["ky", "kentucky"]
      "KY"
    elsif state.in? ["la", "louisiana"]
      "LA"
    elsif state.in? ["me", "maine"]
      "ME"
    elsif state.in? ["md", "maryland"]
      "MD"
    elsif state.in? ["ma", "massachusetts"]
      "MA"
    elsif state.in? ["mi", "michigan"]
      "MI"
    elsif state.in? ["mn", "minnesota"]
      "MN"
    elsif state.in? ["ms", "mississippi"]
      "MS"
    elsif state.in? ["mo", "missouri"]
      "MO"
    elsif state.in? ["mt", "montana"]
      "MT"
    elsif state.in? ["ne", "nebraska"]
      "NE"
    elsif state.in? ["nv", "nevada"]
      "NV"
    elsif state.in? ["nh", "new hampshire"]
      "NH"
    elsif state.in? ["nj", "new jersey"]
      "NJ"
    elsif state.in? ["nm", "new mexico"]
      "NM"
    elsif state.in? ["ny", "new york"]
      "NY"
    elsif state.in? ["nc", "north carolina"]
      "NC"
    elsif state.in? ["nd", "north dakota"]
      "ND"
    elsif state.in? ["oh", "ohio"]
      "OH"
    elsif state.in? ["ok", "oklahoma"]
      "OK"
    elsif state.in? ["or", "oregon"]
      "OR"
    elsif state.in? ["pa", "pennsylvania"]
      "PA"
    elsif state.in? ["ri", "rhode island"]
      "RI"
    elsif state.in? ["sc", "south carolina"]
      "SC"
    elsif state.in? ["sd", "south dakota"]
      "SD"
    elsif state.in? ["tn", "tennessee"]
      "TN"
    elsif state.in? ["tx", "texas"]
      "TX"
    elsif state.in? ["ut", "utah"]
      "UT"
    elsif state.in? ["vt", "vermont"]
      "VT"
    elsif state.in? ["va", "virginia"]
      "VA"
    elsif state.in? ["wa", "washington"]
      "WA"
    elsif state.in? ["wv", "west virginia"]
      "WV"
    elsif state.in? ["wi", "wisconsin"]
      "WI"
    elsif state.in? ["wy", "wyoming"]
      "WY"
    elsif state.in? ["dc", "district of columbia"]
      "DC"
    elsif state.in? ["vi"] # this is not correct, having it here for simplicity's sake for now.
      "VI"
    elsif state.in? ["puerto rico"] # this is not correct, having it here for simplicity's sake for now.
      "PR"
    elsif state.in? ["na"]
      nil
    else
      raise "Invalid US state: #{state}"
    end

    ISO3166::Country["us"].subdivisions[state].name if state.present?
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
      "Newfoundland and Labrador"
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
      "Prince Edward Island"
    elsif province.in? ["yt"]
      "Yukon"
    elsif province.in? ["nb"]
      "New Brunswick"
    else
      raise "Invalid Canadian province: #{province}"
    end
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
