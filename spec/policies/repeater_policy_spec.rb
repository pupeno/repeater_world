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

RSpec.describe RepeaterPolicy do
  subject { described_class }

  context "As anonymous" do
    permissions :index?, :show? do
      it "permits listing and showing repeaters" do
        expect(subject).to permit(nil, subject)
      end
    end

    permissions :new?, :create? do
      it "denies creating repeaters" do
        expect(subject).not_to permit(nil, subject)
      end
    end

    context "with a repeater" do
      before { @repeater = create(:repeater) }

      permissions :edit?, :update?, :destroy? do
        it "denies editing or deleting repeaters" do
          expect(subject).not_to permit(nil, @repeater)
        end
      end
    end
  end

  context "With a user that can't edit repeaters" do
    before { @user = create(:user, can_edit_repeaters: false) }

    permissions :index?, :show? do
      it "permits listing and showing repeaters" do
        expect(subject).to permit(@user, subject)
      end
    end

    permissions :new?, :create? do
      it "permits creating a repeater" do
        expect(subject).to permit(@user, subject)
      end
    end

    context "with a repeater" do
      before { @repeater = create(:repeater) }

      permissions :edit?, :update?, :destroy? do
        it "denies editing or deleting repeaters" do
          expect(subject).not_to permit(@user, @repeater)
        end
      end
    end
  end

  context "With a user that can edit repeaters" do
    before { @user = create(:user, can_edit_repeaters: true) }

    permissions :index?, :show? do
      it "permits listing and showing repeaters" do
        expect(subject).to permit(@user, subject)
      end
    end

    permissions :new?, :create? do
      it "permits creating a repeater" do
        expect(subject).to permit(@user, subject)
      end
    end

    context "with a repeater" do
      before { @repeater = create(:repeater) }

      permissions :edit?, :update? do
        it "permits editing a repeater" do
          expect(subject).to permit(@user, @repeater)
        end
      end

      permissions :destroy? do
        it "denies deleting repeaters" do
          expect(subject).not_to permit(@user, @repeater)
        end
      end
    end
  end
end
