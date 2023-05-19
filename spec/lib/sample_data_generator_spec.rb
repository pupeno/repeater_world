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

require "rails_helper"

RSpec.describe SampleDataGenerator do
  # it's very common for schemas to change and the sample data generator to be neglected, so just running it helps a
  # lot with keeping it in shape.
  context "A sample data generator" do
    before { @generator = SampleDataGenerator.new }

    it "generate" do
      # without crashing, that's all we are testing.
      @generator.generate
    end

    it "should create admins" do
      expect { @generator.send(:create_admins) }.to change { Admin.count }.by(SampleDataGenerator::ADMINS.length)
      # And not delete them, it kills the session and it's annoying:
      expect { @generator.send(:delete_data) }.to change { Admin.count }.by(0)
      # Which means it needs to be idempotent:
      expect { @generator.send(:create_admins) }.to change { Admin.count }.by(0)
    end
  end
end
