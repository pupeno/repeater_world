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

class SampleDataGenerator
  include FactoryBot::Syntax::Methods

  ADMINS = %w[admin].map { |name| "#{name}@example.com" }
  PASSWORD = "TeZlk27HIp403YwthqzrRTrs6"

  def initialize
    raise "Are you out of your vulcan mind?" unless can_run? # Just protect destroying production data.
  end

  def generate
    delete_data
    create_admins
    create_repeaters
    create_users
  end

  private

  def create_admins
    created_any_admins = false
    ADMINS.each do |admin_email|
      admin = Admin.find_or_initialize_by(email: admin_email)
      if admin.new_record?
        admin.password = PASSWORD
        admin.skip_confirmation!
        admin.save!
        Rails.logger.info "Creating administrators..." if !created_any_admins
        Rails.logger.info "  Created \"#{admin_email}\" with password \"#{PASSWORD}\"."
        created_any_admins = true
      end
    end
    Rails.logger.info "Done creating administrators." if created_any_admins
  end

  def create_repeaters
    Rails.logger.info "Creating UK repeaters from saved snapshot..."
    importer = UkrepeatersImporter.new(
      working_directory: Rails.root.join("spec", "factories", "ukrepeaters_importer_data"),
      logger: Logger.new("/dev/null")
    )
    importer.import
    Rails.logger.info "Created UK repeaters from saved snapshot."
  end

  def create_users
    Rails.logger.info "Creating users..."
    _nick_fury = create_user("nick.fury@avengers.asm")
    _tony_stark = create_user("tony.stark@avengers.asm")
    _steve_rogers = create_user("steve.rogers@avengers.asm")
    _natasha_romanoff = create_user("natasha.romanoff@avengers.asm")
    _clint_barton = create_user("clint.barton@avengers.asm")
    _peter_parker = create_user("peter.parker@avengers.asm")
    _thor_odinson = create_user("thor@avengers.asm")
    _robert_banner = create_user("robert.banner@avengers.asm")
    _stephen_stranger = create_user("stephen.strange@avengers.asm")
    _scott_lang = create_user("stepher.strange@avengers.asm")
    _phli_coulson = create_user("phil.coulson@avengers.asm")
    _wanda_maximoff = create_user("wanda.maximoff@avengers.asm")
    _pepper_potts = create_user("pepper.potts@avengers.asm")
    _james_rhodes = create_user("james.rhodes@avengers.asm")
    _vision = create_user("vision@avengers.asm")
    _matt_murdock = create_user("matt.murdock@defenders.alt")
    _jessica_jones = create_user("jessica.jones@defenders.alt")
    _luke_cage = create_user("luke.cage@defenders.alt")
    Rails.logger.info "Done creating users."
  end

  def create_user(email)
    create(:user, email: email)
    Rails.logger.info " Created user \"#{email}\" with password \"#{PASSWORD}\"."
  end

  def delete_data
    Rails.logger.info "Deleting data..."
    table_names = [User, RepeaterSearch, Repeater, SuggestedRepeater].map(&:table_name)
    Rails.logger.info "  Truncating tables: #{table_names.join(", ")}"
    Admin.connection.truncate_tables(*table_names)
    Rails.logger.info "Done deleting data."
  end

  ##
  # Returns whether sample data generation can be run. We can run in dev and testing and during a pull request.
  def can_run?
    Rails.env.development? || Rails.env.test? || ENV["ALLOW_SAMPLE_DATA_GENERATION"] == "true"
  end
end
