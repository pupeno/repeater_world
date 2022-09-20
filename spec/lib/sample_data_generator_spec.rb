require "rails_helper"

RSpec.describe SampleDataGenerator do
  # it's very common for schemas to change and the sample data generator to be neglected, so just running it helps a
  # lot with keeping it in shape.
  context "A sample data generator" do
    before(:all) { SampleDataGenerator.output = StringIO.new }

    before { @generator = SampleDataGenerator.new }

    it "generate" do
      # without crashing, that's all we are testing.
      @generator.generate
    end

    it "should create admins" do
      expect { @generator.create_admins }.to change { Admin.count }.by(SampleDataGenerator::ADMINS.length)
      # And not delete them, it kills the session and it's annoying:
      expect { @generator.delete_data }.to change { Admin.count }.by(0)
      # Which means it needs to be idempotent:
      expect { @generator.create_admins }.to change { Admin.count }.by(0)
    end
  end
end
