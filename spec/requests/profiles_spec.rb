require "rails_helper"

RSpec.describe "/profiles", type: :request do
  context "While logged in" do
    before do
      @current_user = create(:user)
      sign_in @current_user
    end

    describe "GET /edit" do
      it "edits the user profile" do
        get edit_profile_url
        expect(response).to be_successful
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        it "updates the requested profile" do
          current_email = @current_user.email
          new_email = Faker::Internet.unique.email
          patch profile_url, params: {user: {email: new_email}}
          @current_user.reload
          expect(@current_user.email).to eq(current_email)
          expect(@current_user.unconfirmed_email).to eq(new_email)
          expect(response).to redirect_to(edit_profile_url)
        end
      end

      context "with invalid parameters" do
        it "renders a successful response (i.e. to display the 'edit' template)" do
          patch profile_url, params: {user: {email: ""}}
          expect(response).to have_http_status(422)
        end
      end
    end
  end
end
