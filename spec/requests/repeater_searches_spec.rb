# Copyright 2023, Pablo Fernandez
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

RSpec.describe "/repeater_searches", type: :request do
  context "With some repeaters" do
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

    context "as anonymous" do
      it "shows a search form on /" do
        get root_url
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("Search")
        expect(response.body).to include("Save Search")
      end

      it "runs a simple search" do
        get search_url(s: attributes_for(:repeater_search, band_2m: true, fm: true))
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("Search")
        expect(response.body).to include("Save Search")
        expect(response.body).to include("2M FM")
        expect(response.body).not_to include("4M FM")
      end

      it "runs a search by my location" do
        get search_url(s: attributes_for(:repeater_search,
          geosearch_type: RepeaterSearch::MY_LOCATION,
          distance: 160, distance_unit: RepeaterSearch::KM, latitude: 0, longitude: 0))
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("Search")
        expect(response.body).to include("Save Search")
        expect(response.body).to include("2M FM")
        expect(response.body).not_to include("4M FM")
      end

      it "fails to runs a search by my location due to missing coordinates" do
        get search_url(s: attributes_for(:repeater_search,
          geosearch_type: RepeaterSearch::MY_LOCATION,
          distance: 160, distance_unit: RepeaterSearch::KM))
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("We couldn&#39;t get valid coordinates for your location")
      end

      it "runs a search by coordinates" do
        get search_url(s: attributes_for(
          :repeater_search,
          geosearch_type: RepeaterSearch::COORDINATES,
          distance: 160, distance_unit: RepeaterSearch::KM, latitude: 0, longitude: 0
        ))
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("Search")
        expect(response.body).to include("Save Search")
        expect(response.body).to include("2M FM")
        expect(response.body).not_to include("4M FM")
      end

      it "runs a search by coordinates" do
        get search_url(s: attributes_for(:repeater_search,
          geosearch_type: RepeaterSearch::COORDINATES,
          distance: 160, distance_unit: RepeaterSearch::KM))
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("Latitude can&#39;t be blank")
        expect(response.body).to include("Longitude can&#39;t be blank")
      end

      it "runs a search by grid square" do
        get search_url(s: attributes_for(:repeater_search,
          geosearch_type: RepeaterSearch::GRID_SQUARE,
          distance: 160, distance_unit: RepeaterSearch::KM, grid_square: "JJ00"))
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("Search")
        expect(response.body).to include("Save Search")
        expect(response.body).to include("2M FM")
        expect(response.body).not_to include("4M FM")
      end

      it "runs a search by grid square" do
        get search_url(s: attributes_for(:repeater_search,
          geosearch_type: RepeaterSearch::GRID_SQUARE,
          distance: 160, distance_unit: RepeaterSearch::KM))
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("Grid square can&#39;t be blank")
      end

      it "runs a full text search" do
        get search_url(s: attributes_for(:repeater_search, search_terms: "2M"))
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("Search")
        expect(response.body).to include("Save Search")
        expect(response.body).to include("2M FM")
        expect(response.body).not_to include("4M FM")
      end

      it "runs a search with all possible options" do
        get search_url(s: attributes_for(:repeater_search,
          band_10m: true, band_6m: true, band_4m: true, band_2m: true, band_70cm: true, band_23cm: true,
          fm: true, dstar: true, fusion: true, dmr: true, nxdn: true,
          geosearch_type: RepeaterSearch::MY_LOCATION,
          distance: 1000, distance_unit: RepeaterSearch::KM, latitude: 0, longitude: 0), search_terms: "FM")
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("Search")
        expect(response.body).to include("Save Search")
        expect(response.body).to include("2M FM")
        expect(response.body).to include("4M FM")
      end

      it "runs a search and shows the second page" do
        get search_url(s: attributes_for(:repeater_search, band_2m: true, fm: true), p: 2)
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("Search")
        expect(response.body).to include("Save Search")
        expect(response.body).not_to include("2M FM") # It's on the first page, the second page is empty.
        expect(response.body).not_to include("4M FM")
      end

      it "runs a search and ignores the page when showing a map" do
        get search_url(s: attributes_for(:repeater_search, band_2m: true, fm: true), p: 2, d: "map")
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("Search")
        expect(response.body).to include("Save Search")
        expect(response.body).to include("2M FM")
        expect(response.body).not_to include("4M FM")
      end

      it "runs a search generating an exporting link" do
        get search_url(s: attributes_for(:repeater_search, band_2m: true, fm: true), export: true, e: {format: "csv"})
        expect(response).to be_successful
        expect(response).to render_template(:new)
        expect(response.body).to include("Search")
        expect(response.body).to include("Save Search")
        expect(response.body).to include("2M FM")
        expect(response.body).not_to include("4M FM")
        expect(response.body).to include("Download export.csv")
      end

      it "exports by parameters" do
        get export_url(s: attributes_for(:repeater_search, band_2m: true, fm: true),
          e: {format: "csv"})
        expect(response).to be_successful
        expect(response.body).to include("Name,Call Sign,Web Site,Keeper,Band,Operational,Tx Frequency,Rx Frequency,FM,Tone Burst,CTCSS Tone,Tone Squelch,Bandwidth,D-Star,D-Star Port,Fusion,DMR,DMR Color Code,DMR Network,NXDN,P25,Tetra,Latitude,Longitude,Grid Square,Address,Locality,Region,Post Code,Country Code,Tx Power,Tx Antenna,Tx Antenna Polarization,Rx Antenna,Rx Antenna Polarization,Altitude Asl,Altitude Agl,Bearing,UTC Offset,Channel,Notes,Source,Redistribution Limitations")
        expect(response.body).to include("2M FM,")
      end

      it "exports with no parameters of any kind" do
        expect do
          get export_url # I'm not sure what made it happen, the URL was export.php, so probably some crawling searching for exploits.
        end.to raise_exception(ActionController::BadRequest)
      end
    end

    context "as a user" do
      before do
        @current_user = create(:user)
        sign_in @current_user
      end

      it "shows a list of repeater searches" do
        searches = 5.times.collect { create(:repeater_search, user: @current_user) }
        someone_elses_search = create(:repeater_search, name: "Someone else's search", user: create(:user))
        get repeater_searches_url
        expect(response).to be_successful
        searches.each do |search|
          expect(response.body).to include(search.name)
        end
        expect(response.body).not_to include(someone_elses_search.name)
      end

      it "show a simple saved search" do
        repeater_search = create(:repeater_search, user: @current_user)
        get repeater_search_url(repeater_search)
        expect(response).to be_successful
        expect(response.body).to include("2M FM")
        expect(response.body).to include("4M FM")
      end

      it "show a saved band search" do
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

      it "show a saved mode search" do
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

      it "show a saved geo search in km" do
        repeater_search = create(:repeater_search,
          geosearch_type: RepeaterSearch::MY_LOCATION,
          distance: 10, distance_unit: RepeaterSearch::KM, latitude: 0, longitude: 0,
          user: @current_user)
        get repeater_search_url(repeater_search)
        expect(response).to be_successful
        expect(response.body).to include("23CM FM")
        expect(response.body).not_to include("70CM FM")
        expect(response.body).not_to include("2M FM")
        expect(response.body).not_to include("4M FM")
      end

      it "show a a saved geo search in miles" do
        repeater_search = create(:repeater_search,
          geosearch_type: RepeaterSearch::MY_LOCATION,
          distance: 100, distance_unit: RepeaterSearch::MILES, latitude: 0, longitude: 0,
          user: @current_user)
        get repeater_search_url(repeater_search)
        expect(response).to be_successful
        expect(response.body).to include("23CM FM")
        expect(response.body).to include("70CM FM")
        expect(response.body).to include("2M FM")
        expect(response.body).not_to include("4M FM")
      end

      it "shows with export link" do
        repeater_search = create(:repeater_search, user: @current_user)
        get repeater_search_url(repeater_search, export: true, e: {format: "csv"})
        expect(response).to be_successful
        expect(response.body).to include("2M FM")
        expect(response.body).to include("4M FM")
        expect(response.body).to include("Download export.csv")
      end

      it "doesn't run someone else's search" do
        repeater_search = create(:repeater_search, user: create(:user))
        expect do
          get repeater_search_url(repeater_search)
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it "shows an unsaved search over a saved search" do
        repeater_search = create(:repeater_search, user: @current_user)
        get repeater_search_url(repeater_search, s: attributes_for(:repeater_search, band_2m: false, band_4m: true, fm: true))
        expect(response).to be_successful
        expect(response.body).not_to include("2M FM")
        expect(response.body).to include("4M FM")
      end

      it "shows an unsaved search over a saved search, ignoring page because of map mode" do
        repeater_search = create(:repeater_search, user: @current_user)
        get repeater_search_url(repeater_search, s: attributes_for(:repeater_search, band_2m: false, band_4m: true, fm: true), p: 2, d: "map")
        expect(response).to be_successful
        expect(response.body).not_to include("2M FM")
        expect(response.body).to include("4M FM")
      end

      it "exports by id" do
        repeater_search = create(:repeater_search, user: @current_user, band_2m: true, fm: true)
        get export_repeater_search_url(repeater_search, e: {format: "csv"})
        expect(response).to be_successful
        expect(response.body).to include("Name,Call Sign,Web Site,Keeper,Band,Operational,Tx Frequency,Rx Frequency,FM,Tone Burst,CTCSS Tone,Tone Squelch,Bandwidth,D-Star,D-Star Port,Fusion,DMR,DMR Color Code,DMR Network,NXDN,P25,Tetra,Latitude,Longitude,Grid Square,Address,Locality,Region,Post Code,Country Code,Tx Power,Tx Antenna,Tx Antenna Polarization,Rx Antenna,Rx Antenna Polarization,Altitude Asl,Altitude Agl,Bearing,UTC Offset,Channel,Notes,Source,Redistribution Limitations")
        expect(response.body).to include("2M FM,")
      end

      it "creates a new repeater search" do
        expect {
          post repeater_searches_url, params: {s: attributes_for(:repeater_search)}
        }.to change(RepeaterSearch, :count).by(1)
        expect(response).to redirect_to(repeater_search_url(RepeaterSearch.last))
      end

      it "fails to create a new repeater search" do
        expect {
          post repeater_searches_url, params: {s: attributes_for(:repeater_search).merge({distance: "hello"})}
        }.to change(RepeaterSearch, :count).by(0)
        expect(response).to have_http_status(422)
      end

      it "updates a repeater search" do
        repeater_search = create(:repeater_search, user: @current_user)
        patch repeater_search_url(repeater_search), params: {s: {dmr: true}}
        repeater_search.reload
        expect(repeater_search.dmr?).to be true
        expect(response).to redirect_to(repeater_search_url(repeater_search))
      end

      it "redirects to export a repeater search" do
        repeater_search = create(:repeater_search, user: @current_user)
        patch repeater_search_url(repeater_search), params: {s: {dmr: true}, export: true, e: {format: "csv"}}
        repeater_search.reload
        expect(repeater_search.dmr?).to be true
        expect(response).to redirect_to(repeater_search_url(repeater_search, export: true, e: {format: "csv"}))
      end

      it "fails to update due to validations" do
        repeater_search = create(:repeater_search, user: @current_user)
        patch repeater_search_url(repeater_search), params: {s: {distance: "hello"}}
        expect(response).to have_http_status(422)
      end

      it "fails to update due search belonging to someone else" do
        repeater_search = create(:repeater_search, user: create(:user))
        expect do
          patch repeater_search_url(repeater_search), params: {s: {dmr: true}}
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it "deletes a repeater search" do
        repeater_search = create(:repeater_search, user: @current_user)
        expect {
          delete repeater_search_url(repeater_search)
        }.to change(RepeaterSearch, :count).by(-1)
        expect(response).to redirect_to(repeater_searches_url)
      end

      it "fails to delete a repeater search belonging to someone else" do
        repeater_search = create(:repeater_search, user: create(:user))
        expect do
          delete repeater_search_url(repeater_search)
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
end
