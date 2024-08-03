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

RSpec.describe "/repeaters", type: :request do
  context "As anonymous" do
    it "shows a repeater full of data" do
      repeater = create(:repeater, :full,
        name: "A Repeater",
        call_sign: "C4LLS1GN",
        tx_frequency: 144_962_500,
        rx_frequency: 144_362_500)
      get repeater_url(repeater)
      expect(response).to be_successful
      expect(response.body).to include("A Repeater")
      expect(response.body).to include("C4LLS1GN")
      expect(response.body).to include("144.9625MHz")
      expect(response.body).to include("144.3625MHz")
      expect(response.body).to include("-600kHz")
    end

    it "shows a repeater void of data" do
      repeater = create(:repeater)
      get repeater_url(repeater)
      expect(response).to be_successful # We are mostly checking for crashes due to assuming a value exists.
    end

    it "redirects from an old slug" do
      repeater = create(:repeater)
      get repeater_url("#{repeater.id}-#{repeater.name}")
      expect(response).to redirect_to(repeater_url(repeater))
    end

    it "shows a 404 when a repeater is not found" do
      expect do
        get repeater_url("not-an-existing-repeater")
      end.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "denies creating repeaters" do
      get new_repeater_url
      expect(response).to redirect_to(new_user_registration_url)
      follow_redirect!
      expect(response.body).to include("To be able to create repeaters you need to sign up or log in.")
    end

    it "denies creating repeaters" do
      expect do
        post repeaters_url, params: {repeater: attributes_for(:repeater)}
      end.to change { Repeater.count }.by(0)
      expect(response).to redirect_to(new_user_registration_url)
      follow_redirect!
      expect(response.body).to include("To be able to create repeaters you need to sign up or log in.")
    end

    context "with a repeater" do
      before { @repeater = create(:repeater) }

      it "denies editing a repeater" do
        get edit_repeater_url(@repeater)
        expect(response).to redirect_to(new_user_registration_url)
        follow_redirect!
        expect(response.body).to include("To be able to edit repeaters you need to log in or sign up. If you are signing up with a new account, you also need to reach out to info@repeater.world to have editing repeaters activated.")
      end

      it "denies updated a repeater" do
        patch repeater_url(@repeater), params: {repeater: attributes_for(:repeater)}
        expect(response).to redirect_to(new_user_registration_url)
        follow_redirect!
        expect(response.body).to include("To be able to edit repeaters you need to log in or sign up. If you are signing up with a new account, you also need to reach out to info@repeater.world to have editing repeaters activated.")
      end
    end
  end

  context "With a user that can't edit repeaters" do
    before do
      @current_user = create(:user, can_edit_repeaters: false)
      sign_in @current_user
    end

    it "gets the new repeater form" do
      get new_repeater_url
      expect(response).to be_successful
      expect(response.body).to include("Add a New Repeater")
    end

    it "creates a new repeater" do
      expect do
        post repeaters_url, params: {repeater: attributes_for(:repeater)}
      end.to change { Repeater.count }.by(1)
        .and change { ActionMailer::Base.deliveries.count }.by(1)
      repeater = Repeater.last
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq("New repeater added Repeater BL4NK")
      expect(email.body.to_s).to include("New repeater added Repeater BL4NK")
      expect(email.body.to_s).to include(repeater.to_s)
      expect(email.body.to_s).to include(@current_user.to_s)
      expect(response).to redirect_to(repeater_url(repeater))
      follow_redirect!
      expect(response.body).to include(repeater.moniker)
      expect(response.body).to include("Thank you. Your repeater is now live.")
    end

    it "fails to create a new repeater due to validation" do
      expect do
        post repeaters_url, params: {repeater: {}}
      end.to change { Repeater.count }.by(0)
        .and change { ActionMailer::Base.deliveries.count }.by(0)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    context "with a repeater" do
      before { @repeater = create(:repeater) }

      it "denies editing a repeater" do
        get edit_repeater_url(@repeater)
        expect(response).to redirect_to(repeater_url(@repeater))
        follow_redirect!
        expect(response.body).to include("To be able to edit repeaters you need to get in touch with us at info@repeater.world.")
      end

      it "denies updated a repeater" do
        patch repeater_url(@repeater), params: {repeater: attributes_for(:repeater)}
        expect(response).to redirect_to(repeater_url(@repeater))
        follow_redirect!
        expect(response.body).to include("To be able to edit repeaters you need to get in touch with us at info@repeater.world.")
      end
    end
  end

  context "With a user that can edit repeaters" do
    before do
      @current_user = create(:user, can_edit_repeaters: true)
      sign_in @current_user
    end

    context "with a repeater" do
      before { @repeater = create(:repeater) }

      it "gets the edit repeater form" do
        get edit_repeater_url(@repeater)
        expect(response).to be_successful
        expect(response.body).to include("Update Repeater #{@repeater.moniker}")
      end

      it "redirects edit form from an old slug" do
        repeater = create(:repeater)
        get edit_repeater_url("#{repeater.id}-#{repeater.name}")
        expect(response).to redirect_to(edit_repeater_url(repeater))
      end

      it "updates an existing repeater" do
        expect do
          patch repeater_url(@repeater), params: {repeater: attributes_for(:repeater)}
        end.to change { Repeater.count }.by(0)
          .and change { ActionMailer::Base.deliveries.count }.by(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eq("Repeater updated #{@repeater.moniker}")
        expect(email.body.to_s).to include("Repeater updated")
        expect(email.body.to_s).to include(@repeater.to_s)
        expect(email.body.to_s).to include(@current_user.to_s)
        expect(response).to redirect_to(repeater_url(@repeater))
        follow_redirect!
        expect(response.body).to include(@repeater.moniker)
        expect(response.body).to include("Thank you. The details for this repeater have been updated.")
      end

      it "fails to update an existing repeater due to validation errors" do
        expect do
          patch repeater_url(@repeater), params: {repeater: {call_sign: ""}}
        end.to change { Repeater.count }.by(0)
          .and change { ActionMailer::Base.deliveries.count }.by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
