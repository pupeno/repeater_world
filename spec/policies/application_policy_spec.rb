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

require "rails_helper"

RSpec.describe ApplicationPolicy do
  subject { described_class }

  permissions :index?, :show?, :new?, :create?, :edit?, :update?, :destroy? do
    it "denies everything" do
      expect(subject).not_to permit(nil, nil)
    end
  end

  it "has a scope" do
    user = create(:user)
    scope = ApplicationPolicy::Scope.new(user, RepeaterSearch)
    expect { scope.resolve }.to raise_error(NotImplementedError)
  end
end
