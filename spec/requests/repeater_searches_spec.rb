require "rails_helper"

RSpec.describe "/repeater_searches", type: :request do
  context "With repeaters" do
    before(:all) do
      Repeater.destroy_all
      create(:repeater, name: "23CM FM", fm: true, band: Repeater::BAND_23CM, latitude: 0, longitude: 0.07, location: "POINT(0 0.07)")
      create(:repeater, name: "70CM FM", fm: true, band: Repeater::BAND_70CM, latitude: 0, longitude: 0.13, location: "POINT(0 0.13)")
      create(:repeater, name: "2M FM", fm: true, band: Repeater::BAND_2M, latitude: 0, longitude: 1.4, location: "POINT(0 1.4)")
      create(:repeater, name: "4M FM", fm: true, band: Repeater::BAND_4M, latitude: 0, longitude: 2, location: "POINT(0 2)")
      create(:repeater, name: "23CM D-Star", dstar: true, band: Repeater::BAND_23CM)
      create(:repeater, name: "70CM Fusion", fusion: true, band: Repeater::BAND_70CM)
      create(:repeater, name: "2M DMR", dmr: true, band: Repeater::BAND_2M)
      create(:repeater, name: "4M NXDN", nxdn: true, band: Repeater::BAND_4M)
    end

    it "shows a search form on /" do
      get root_url
      expect(response).to be_successful
      expect(response).to render_template(:new)
      expect(response.body).to include("Search")
      expect(response.body).to include("Save Search")
    end

    it "runs a search" do
      get search_url(s: attributes_for(:repeater_search, band_2m: true, fm: true))
      expect(response).to be_successful
      expect(response).to render_template(:new)
      expect(response.body).to include("Search")
      expect(response.body).to include("Save Search")
      expect(response.body).to include("2M FM")
      expect(response.body).not_to include("4M FM")
    end

    describe "GET /new" do
      it "renders a successful response" do
        get new_repeater_search_url
        expect(response).to be_successful
      end
    end

    context "while logged in" do
      before do
        @current_user = create(:user)
        sign_in @current_user
      end

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
          repeater_search = create(:repeater_search, user: @current_user)
          get repeater_search_url(repeater_search)
          expect(response).to be_successful
          expect(response.body).to include("2M FM")
          expect(response.body).to include("4M FM")
        end

        it "run a band search" do
          repeater_search = create(:repeater_search, band_2m: true, user: @current_user)
          get repeater_search_url(repeater_search)
          expect(response).to be_successful
          expect(response.body).not_to include("23CM FM")
          expect(response.body).to include("2M FM")
          expect(response.body).not_to include("4M FM")

          repeater_search.band_23cm = true
          repeater_search.save!
          get repeater_search_url(repeater_search)
          expect(response).to be_successful
          expect(response.body).to include("23CM FM")
          expect(response.body).to include("2M FM")
          expect(response.body).not_to include("4M FM")
        end

        it "run a mode search" do
          repeater_search = create(:repeater_search, fm: true, user: @current_user)
          get repeater_search_url(repeater_search)
          expect(response).to be_successful
          expect(response.body).to include("2M FM")
          expect(response.body).not_to include("23CM D-Star")
          expect(response.body).not_to include("70CM Fusion")
          expect(response.body).not_to include("2M DMR")
          expect(response.body).not_to include("4M NXDN")

          repeater_search.dstar = true
          repeater_search.fusion = true
          repeater_search.save!
          get repeater_search_url(repeater_search)
          expect(response).to be_successful
          expect(response.body).to include("2M FM")
          expect(response.body).to include("23CM D-Star")
          expect(response.body).to include("70CM Fusion")
          expect(response.body).not_to include("2M DMR")
          expect(response.body).not_to include("4M NXDN")
        end

        it "runs a geo search in km" do
          repeater_search = create(:repeater_search, distance_to_coordinates: true, distance: 10,
            distance_unit: RepeaterSearch::KM, latitude: 0, longitude: 0,
            user: @current_user)
          get repeater_search_url(repeater_search)
          expect(response).to be_successful
          expect(response.body).to include("23CM FM")
          expect(response.body).not_to include("70CM FM")
          expect(response.body).not_to include("2M FM")
          expect(response.body).not_to include("4M FM")
        end

        it "runs a geo search in miles" do
          repeater_search = create(:repeater_search, distance_to_coordinates: true, distance: 100,
            distance_unit: RepeaterSearch::MILES, latitude: 0, longitude: 0,
            user: @current_user)
          get repeater_search_url(repeater_search)
          expect(response).to be_successful
          expect(response.body).to include("23CM FM")
          expect(response.body).to include("70CM FM")
          expect(response.body).to include("2M FM")
          expect(response.body).not_to include("4M FM")
        end
      end

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
              post repeater_searches_url, params: {s: attributes_for(:repeater_search).merge({distance: "hello"})}
            }.to change(RepeaterSearch, :count).by(0)
            expect(response).to have_http_status(422)
          end
        end
      end

      describe "PATCH /update" do
        context "with valid parameters" do
          it "updates the requested repeater_search" do
            repeater_search = create(:repeater_search, user: @current_user)
            patch repeater_search_url(repeater_search), params: {s: {dmr: true}}
            repeater_search.reload
            expect(repeater_search.dmr?).to be true
            expect(response).to redirect_to(repeater_search_url(repeater_search))
          end
        end

        context "with invalid parameters" do
          it "renders a successful response (i.e. to display the 'edit' template)" do
            repeater_search = create(:repeater_search, user: @current_user)
            patch repeater_search_url(repeater_search), params: {s: {distance: "hello"}}
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

    # TODO: not implemented yet.
    # describe "GET /edit" do
    #   it "renders a successful response" do
    #     repeater_search = RepeaterSearch.create! valid_attributes
    #     get edit_repeater_search_url(repeater_search)
    #     expect(response).to be_successful
    #   end
    # end
  end
end
