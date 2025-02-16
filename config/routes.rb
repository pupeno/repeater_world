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

Rails.application.routes.draw do
  # Admin
  mount RailsAdmin::Engine => "/admin", :as => "rails_admin"
  devise_for :admins

  # Root URL and searching.
  root "repeater_searches#new"
  get "search", to: "repeater_searches#new"
  get "export", to: "repeater_searches#export"

  resources :repeater_searches, only: [:index, :create, :show, :update, :destroy] do
    member do
      get "export"
    end
  end
  resources :repeaters, only: [:show, :new, :create, :edit, :update]
  get "/directory", to: "directory#countries"
  get "/directory/:country_id", to: "directory#by_country", as: "directory_by_country"

  # User and profile.
  devise_for :users
  resource :profile, only: [:edit, :update]

  # API
  namespace :api do
    namespace :next do
      resources :repeaters, only: [:index]
    end
  end

  # Boring routes.
  get "sitemap", to: "static#sitemap"
  get "values", to: "static#values"
  get "map-legend", to: "static#map_legend"
  get "data-limitations/ukrepeater-net", to: "static#ukrepeater_net"
  get "data-limitations/sral-fi", to: "static#sral_fi"
  get "crawler", to: "static#crawler"
  get "privacy-policy", to: "static#privacy_policy"
  get "cookie-policy", to: "static#cookie_policy"
  get "404", to: "static#not_found"
  get "ui", to: "static#ui"

  # Redirections
  get "open-source", to: redirect("/values")
  get "open-source-open-data", to: redirect("/values")

  # Fail!
  get "fail", to: "static#fail"
  get "fail-fe", to: "static#fail_fe"
  get "fail-bg", to: "static#fail_bg"
end
