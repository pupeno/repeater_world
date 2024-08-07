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

class SampleDataGenerator
  include FactoryBot::Syntax::Methods

  ADMINS = %w[admin].map { |name| "#{name}@example.com" }
  PASSWORD = "TeZlk27HIp403YwthqzrRTrs6"

  def initialize
    raise "Are you out of your vulcan mind?" unless can_run? # Just protect destroying production data.
  end

  def generate(mode: :full)
    if mode == :full
      delete_data
    end
    create_admins
    create_users
  end

  private

  def delete_data
    Rails.logger.info "Deleting data..."
    table_names = [User, RepeaterSearch, Repeater, SuggestedRepeater].map(&:table_name)
    Rails.logger.info "  Truncating tables: #{table_names.join(", ")}"
    Admin.connection.truncate_tables(*table_names)
    Rails.logger.info "Done deleting data."
  end

  def create_admins
    ADMINS.each do |admin_email|
      admin = Admin.find_or_initialize_by(email: admin_email)
      admin.password = PASSWORD
      admin.skip_confirmation!
      admin.save!
      Rails.logger.info "Creating (or updating) admins..."
      Rails.logger.info "  \"#{admin_email}\" with password \"#{PASSWORD}\"."
    end
    Rails.logger.info "Done creating (or updating) admins."
  end

  def create_users
    Rails.logger.info "Creating (or updating) users..."
    _nick_fury = create_user(email: "nick.fury@avengers.asm", can_edit_repeaters: true)
    _tony_stark = create_user(email: "tony.stark@avengers.asm")
    _steve_rogers = create_user(email: "steve.rogers@avengers.asm")
    _natasha_romanoff = create_user(email: "natasha.romanoff@avengers.asm")
    _clint_barton = create_user(email: "clint.barton@avengers.asm")
    _peter_parker = create_user(email: "peter.parker@avengers.asm")
    _thor_odinson = create_user(email: "thor@avengers.asm")
    _robert_banner = create_user(email: "robert.banner@avengers.asm")
    _stephen_stranger = create_user(email: "stephen.strange@avengers.asm")
    _scott_lang = create_user(email: "stepher.strange@avengers.asm")
    _phli_coulson = create_user(email: "phil.coulson@avengers.asm")
    _wanda_maximoff = create_user(email: "wanda.maximoff@avengers.asm")
    _pepper_potts = create_user(email: "pepper.potts@avengers.asm")
    _james_rhodes = create_user(email: "james.rhodes@avengers.asm")
    _vision = create_user(email: "vision@avengers.asm")
    _matt_murdock = create_user(email: "matt.murdock@defenders.alt")
    _jessica_jones = create_user(email: "jessica.jones@defenders.alt")
    _luke_cage = create_user(email: "luke.cage@defenders.alt")
    Rails.logger.info "Done creating users."
  end

  def create_user(**args)
    user = User.find_by(email: args[:email])
    if user.blank?
      user = create(:user, **args)
    end
    user.assign_attributes(**args)
    user.password = PASSWORD
    user.skip_confirmation!
    user.save!
    Rails.logger.info "  \"#{args[:email]}\" has password \"#{PASSWORD}\"."
    user
  end

  ##
  # Returns whether sample data generation can be run. We can run in dev and testing and during a pull request.
  def can_run?
    Rails.env.development? || Rails.env.test? || ENV["ALLOW_SAMPLE_DATA_GENERATION"] == "true"
  end
end
