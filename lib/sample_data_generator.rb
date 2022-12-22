class SampleDataGenerator
  include FactoryBot::Syntax::Methods

  ADMINS = %w[admin].map { |name| "#{name}@example.com" }
  PASSWORD = "TeZlk27HIp403YwthqzrRTrs6"

  def initialize
    raise "Are you out of your vulcan mind?" unless can_run? # Just protect destroying production data.
  end

  def generate
    previous_stdout_sync = $stdout.sync
    $stdout.sync = true

    delete_data

    create_admins

    create_users
  ensure
    $stdout.sync = previous_stdout_sync
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
        self.class.puts "Creating administrators:" if !created_any_admins
        self.class.puts "  Created \"#{admin_email}\" with password \"#{PASSWORD}\"."
        created_any_admins = true
      end
    end
    self.class.puts "Done creating administrators.\n\n" if created_any_admins
  end

  def create_users
    self.class.print "Creating Avengers..."
    _nick_fury = create(:user, email: "nick.fury@avengers.asm")
    _tony_stark = create(:user, email: "tony.stark@avengers.asm")
    _steve_rogers = create(:user, email: "steve.rogers@avengers.asm")
    _natasha_romanoff = create(:user, email: "natasha.romanoff@avengers.asm")
    _clint_barton = create(:user, email: "clint.barton@avengers.asm")
    _peter_parker = create(:user, email: "peter.parker@avengers.asm")
    _thor_odinson = create(:user, email: "thor@avengers.asm")
    _robert_banner = create(:user, email: "robert.banner@avengers.asm")
    _stephen_stranger = create(:user, email: "stephen.strange@avengers.asm")
    _scott_lang = create(:user, email: "stepher.strange@avengers.asm")
    _phli_coulson = create(:user, email: "phil.coulson@avengers.asm")
    _wanda_maximoff = create(:user, email: "wanda.maximoff@avengers.asm")
    _pepper_potts = create(:user, email: "pepper.potts@avengers.asm")
    _james_rhodes = create(:user, email: "james.rhodes@avengers.asm")
    _vision = create(:user, email: "vision@avengers.asm")
    _matt_murdock = create(:user, email: "matt.murdock@defenders.alt")
    _jessica_jones = create(:user, email: "jessica.jones@defenders.alt")
    _luke_cage = create(:user, email: "luke.cage@defenders.alt")
    self.class.puts "done"
  end

  def delete_data
    self.class.puts "Deleting data..."

    table_names = [User].map(&:table_name)

    self.class.print "  Truncating tables: #{table_names.join(", ")}..."
    Admin.connection.truncate_tables(*table_names)
    self.class.puts " done."
    self.class.puts "Done deleting data.\n\n"
  end

  class << self
    attr_accessor :output
  end

  ##
  # Wrapper around puts that respects the verbosity setting. It's a class method so that factories can call it.
  def self.puts(obj, ...)
    (output || $stdout).puts(obj, ...)
  end

  ##
  # Wrapper around print that respects the verbosity setting. It's a class method so that factories can call it.
  def self.print(obj, ...)
    (output || $stdout).print(obj, ...)
  end

  private

  ##
  # Returns whether sample data generation can be run. We can run in dev and testing and during a pull request.
  def can_run?
    Rails.env.development? || Rails.env.test? || ENV["ALLOW_SAMPLE_DATA_GENERATION"] == "true"
  end
end
