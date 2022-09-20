desc "Generate sample data for development, staging, review apps."
task generate_sample_data: :environment do
  Rake::Task["db:seed"].execute
  SampleDataGenerator.new.generate
end
