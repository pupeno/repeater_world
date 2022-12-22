desc "Generate sample data for development, staging, review apps."
task generate_sample_data: :environment do
  $stdout.sync = true
  Rails.logger = Logger.new(STDOUT)
  Rake::Task["db:seed"].execute
  SampleDataGenerator.new.generate
end
