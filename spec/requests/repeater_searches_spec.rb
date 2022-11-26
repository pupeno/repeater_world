require "rails_helper"

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/repeater_searches", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # RepeaterSearch. As you add validations to RepeaterSearch, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      RepeaterSearch.create! valid_attributes
      get repeater_searches_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      repeater_search = RepeaterSearch.create! valid_attributes
      get repeater_search_url(repeater_search)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_repeater_search_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      repeater_search = RepeaterSearch.create! valid_attributes
      get edit_repeater_search_url(repeater_search)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new RepeaterSearch" do
        expect {
          post repeater_searches_url, params: {repeater_search: valid_attributes}
        }.to change(RepeaterSearch, :count).by(1)
      end

      it "redirects to the created repeater_search" do
        post repeater_searches_url, params: {repeater_search: valid_attributes}
        expect(response).to redirect_to(repeater_search_url(RepeaterSearch.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new RepeaterSearch" do
        expect {
          post repeater_searches_url, params: {repeater_search: invalid_attributes}
        }.to change(RepeaterSearch, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post repeater_searches_url, params: {repeater_search: invalid_attributes}
        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested repeater_search" do
        repeater_search = RepeaterSearch.create! valid_attributes
        patch repeater_search_url(repeater_search), params: {repeater_search: new_attributes}
        repeater_search.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the repeater_search" do
        repeater_search = RepeaterSearch.create! valid_attributes
        patch repeater_search_url(repeater_search), params: {repeater_search: new_attributes}
        repeater_search.reload
        expect(response).to redirect_to(repeater_search_url(repeater_search))
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        repeater_search = RepeaterSearch.create! valid_attributes
        patch repeater_search_url(repeater_search), params: {repeater_search: invalid_attributes}
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested repeater_search" do
      repeater_search = RepeaterSearch.create! valid_attributes
      expect {
        delete repeater_search_url(repeater_search)
      }.to change(RepeaterSearch, :count).by(-1)
    end

    it "redirects to the repeater_searches list" do
      repeater_search = RepeaterSearch.create! valid_attributes
      delete repeater_search_url(repeater_search)
      expect(response).to redirect_to(repeater_searches_url)
    end
  end
end