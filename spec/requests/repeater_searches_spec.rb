require "rails_helper"

RSpec.describe "/repeater_searches", type: :request do
  # TODO: not implemented yet.
  # describe "GET /index" do
  #   it "renders a successful response" do
  #     RepeaterSearch.create! valid_attributes
  #     get repeater_searches_url
  #     expect(response).to be_successful
  #   end
  # end

  describe "GET /show" do
    it "run an empty search" do
      repeater_search = create(:repeater_search)
      get repeater_search_url(repeater_search)
      expect(response).to be_successful
    end

    it "run a band search" do
      repeater_search = create(:repeater_search, band_2m: true)
      get repeater_search_url(repeater_search)
      expect(response).to be_successful

      repeater_search.band_23cm = true
      repeater_search.save!
      get repeater_search_url(repeater_search)
      expect(response).to be_successful
    end

    it "run a mode search" do
      repeater_search = create(:repeater_search, fm: true)
      get repeater_search_url(repeater_search)
      expect(response).to be_successful

      repeater_search.dstar = true
      repeater_search.fusion = true
      repeater_search.save!
      get repeater_search_url(repeater_search)
      expect(response).to be_successful
    end

    it "runs a geo search in km" do
      repeater_search = create(:repeater_search, distance_to_coordinates: true, distance: 10,
        distance_unit: RepeaterSearch::KM, latitude: 0, longitude: 0)
      get repeater_search_url(repeater_search)
      expect(response).to be_successful
    end

    it "runs a geo search in km" do
      repeater_search = create(:repeater_search, distance_to_coordinates: true, distance: 100,
        distance_unit: RepeaterSearch::MILES, latitude: 0, longitude: 0)
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

  # TODO: not implemented yet.
  # describe "GET /edit" do
  #   it "renders a successful response" do
  #     repeater_search = RepeaterSearch.create! valid_attributes
  #     get edit_repeater_search_url(repeater_search)
  #     expect(response).to be_successful
  #   end
  # end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new RepeaterSearch" do
        expect {
          post repeater_searches_url, params: attributes_for(:repeater_search)
        }.to change(RepeaterSearch, :count).by(1)
        expect(response).to redirect_to(repeater_search_url(RepeaterSearch.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new RepeaterSearch" do
        expect {
          post repeater_searches_url, params: {repeater_search: attributes_for(:repeater_search).merge({distance: "hello"})}
        }.to change(RepeaterSearch, :count).by(0)
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested repeater_search" do
        repeater_search = create(:repeater_search)
        patch repeater_search_url(repeater_search), params: {repeater_search: {fm: true}}
        repeater_search.reload
        expect(repeater_search.fm?).to be true
        expect(response).to redirect_to(repeater_search_url(repeater_search))
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        repeater_search = repeater_search = create(:repeater_search)
        patch repeater_search_url(repeater_search), params: {repeater_search: {distance: "hello"}}
        expect(response).to have_http_status(422)
      end
    end
  end

  # TODO: not implemented yet.
  # describe "DELETE /destroy" do
  #   it "destroys the requested repeater_search" do
  #     repeater_search = RepeaterSearch.create! valid_attributes
  #     expect {
  #       delete repeater_search_url(repeater_search)
  #     }.to change(RepeaterSearch, :count).by(-1)
  #   end
  #
  #   it "redirects to the repeater_searches list" do
  #     repeater_search = RepeaterSearch.create! valid_attributes
  #     delete repeater_search_url(repeater_search)
  #     expect(response).to redirect_to(repeater_searches_url)
  #   end
  # end
end
