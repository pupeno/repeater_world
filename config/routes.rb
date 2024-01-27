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
  resources :repeaters, only: [:show]
  resources :suggested_repeaters, only: [:new, :create]
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

# == Route Map
#
#                                   Prefix Verb   URI Pattern                                                                                       Controller#Action
#                              rails_admin        /admin                                                                                            RailsAdmin::Engine
#                        new_admin_session GET    /admins/sign_in(.:format)                                                                         devise/sessions#new
#                            admin_session POST   /admins/sign_in(.:format)                                                                         devise/sessions#create
#                    destroy_admin_session DELETE /admins/sign_out(.:format)                                                                        devise/sessions#destroy
#                       new_admin_password GET    /admins/password/new(.:format)                                                                    devise/passwords#new
#                      edit_admin_password GET    /admins/password/edit(.:format)                                                                   devise/passwords#edit
#                           admin_password PATCH  /admins/password(.:format)                                                                        devise/passwords#update
#                                          PUT    /admins/password(.:format)                                                                        devise/passwords#update
#                                          POST   /admins/password(.:format)                                                                        devise/passwords#create
#                   new_admin_confirmation GET    /admins/confirmation/new(.:format)                                                                devise/confirmations#new
#                       admin_confirmation GET    /admins/confirmation(.:format)                                                                    devise/confirmations#show
#                                          POST   /admins/confirmation(.:format)                                                                    devise/confirmations#create
#                         new_admin_unlock GET    /admins/unlock/new(.:format)                                                                      devise/unlocks#new
#                             admin_unlock GET    /admins/unlock(.:format)                                                                          devise/unlocks#show
#                                          POST   /admins/unlock(.:format)                                                                          devise/unlocks#create
#                                     root GET    /                                                                                                 repeater_searches#new
#                                   search GET    /search(.:format)                                                                                 repeater_searches#new
#                                   export GET    /export(.:format)                                                                                 repeater_searches#export
#                   export_repeater_search GET    /repeater_searches/:id/export(.:format)                                                           repeater_searches#export
#                        repeater_searches GET    /repeater_searches(.:format)                                                                      repeater_searches#index
#                                          POST   /repeater_searches(.:format)                                                                      repeater_searches#create
#                          repeater_search GET    /repeater_searches/:id(.:format)                                                                  repeater_searches#show
#                                          PATCH  /repeater_searches/:id(.:format)                                                                  repeater_searches#update
#                                          PUT    /repeater_searches/:id(.:format)                                                                  repeater_searches#update
#                                          DELETE /repeater_searches/:id(.:format)                                                                  repeater_searches#destroy
#                                 repeater GET    /repeaters/:id(.:format)                                                                          repeaters#show
#                      suggested_repeaters POST   /suggested_repeaters(.:format)                                                                    suggested_repeaters#create
#                   new_suggested_repeater GET    /suggested_repeaters/new(.:format)                                                                suggested_repeaters#new
#                                directory GET    /directory(.:format)                                                                              directory#countries
#                     directory_by_country GET    /directory/:country_id(.:format)                                                                  directory#by_country
#                         new_user_session GET    /users/sign_in(.:format)                                                                          devise/sessions#new
#                             user_session POST   /users/sign_in(.:format)                                                                          devise/sessions#create
#                     destroy_user_session DELETE /users/sign_out(.:format)                                                                         devise/sessions#destroy
#                        new_user_password GET    /users/password/new(.:format)                                                                     devise/passwords#new
#                       edit_user_password GET    /users/password/edit(.:format)                                                                    devise/passwords#edit
#                            user_password PATCH  /users/password(.:format)                                                                         devise/passwords#update
#                                          PUT    /users/password(.:format)                                                                         devise/passwords#update
#                                          POST   /users/password(.:format)                                                                         devise/passwords#create
#                 cancel_user_registration GET    /users/cancel(.:format)                                                                           devise/registrations#cancel
#                    new_user_registration GET    /users/sign_up(.:format)                                                                          devise/registrations#new
#                   edit_user_registration GET    /users/edit(.:format)                                                                             devise/registrations#edit
#                        user_registration PATCH  /users(.:format)                                                                                  devise/registrations#update
#                                          PUT    /users(.:format)                                                                                  devise/registrations#update
#                                          DELETE /users(.:format)                                                                                  devise/registrations#destroy
#                                          POST   /users(.:format)                                                                                  devise/registrations#create
#                    new_user_confirmation GET    /users/confirmation/new(.:format)                                                                 devise/confirmations#new
#                        user_confirmation GET    /users/confirmation(.:format)                                                                     devise/confirmations#show
#                                          POST   /users/confirmation(.:format)                                                                     devise/confirmations#create
#                          new_user_unlock GET    /users/unlock/new(.:format)                                                                       devise/unlocks#new
#                              user_unlock GET    /users/unlock(.:format)                                                                           devise/unlocks#show
#                                          POST   /users/unlock(.:format)                                                                           devise/unlocks#create
#                             edit_profile GET    /profile/edit(.:format)                                                                           profiles#edit
#                                  profile PATCH  /profile(.:format)                                                                                profiles#update
#                                          PUT    /profile(.:format)                                                                                profiles#update
#                       api_next_repeaters GET    /api/next/repeaters(.:format)                                                                     api/next/repeaters#index
#                                  sitemap GET    /sitemap(.:format)                                                                                static#sitemap
#                                   values GET    /values(.:format)                                                                                 static#values
#                               map_legend GET    /map-legend(.:format)                                                                             static#map_legend
#          data_limitations_ukrepeater_net GET    /data-limitations/ukrepeater-net(.:format)                                                        static#ukrepeater_net
#                 data_limitations_sral_fi GET    /data-limitations/sral-fi(.:format)                                                               static#sral_fi
#                                  crawler GET    /crawler(.:format)                                                                                static#crawler
#                           privacy_policy GET    /privacy-policy(.:format)                                                                         static#privacy_policy
#                            cookie_policy GET    /cookie-policy(.:format)                                                                          static#cookie_policy
#                                          GET    /404(.:format)                                                                                    static#not_found
#                                       ui GET    /ui(.:format)                                                                                     static#ui
#                              open_source GET    /open-source(.:format)                                                                            redirect(301, /values)
#                    open_source_open_data GET    /open-source-open-data(.:format)                                                                  redirect(301, /values)
#                                     fail GET    /fail(.:format)                                                                                   static#fail
#                                  fail_fe GET    /fail-fe(.:format)                                                                                static#fail_fe
#                                  fail_bg GET    /fail-bg(.:format)                                                                                static#fail_bg
#         turbo_recede_historical_location GET    /recede_historical_location(.:format)                                                             turbo/native/navigation#recede
#         turbo_resume_historical_location GET    /resume_historical_location(.:format)                                                             turbo/native/navigation#resume
#        turbo_refresh_historical_location GET    /refresh_historical_location(.:format)                                                            turbo/native/navigation#refresh
#            rails_postmark_inbound_emails POST   /rails/action_mailbox/postmark/inbound_emails(.:format)                                           action_mailbox/ingresses/postmark/inbound_emails#create
#               rails_relay_inbound_emails POST   /rails/action_mailbox/relay/inbound_emails(.:format)                                              action_mailbox/ingresses/relay/inbound_emails#create
#            rails_sendgrid_inbound_emails POST   /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                           action_mailbox/ingresses/sendgrid/inbound_emails#create
#      rails_mandrill_inbound_health_check GET    /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#health_check
#            rails_mandrill_inbound_emails POST   /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#create
#             rails_mailgun_inbound_emails POST   /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                                       action_mailbox/ingresses/mailgun/inbound_emails#create
#           rails_conductor_inbound_emails GET    /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#index
#                                          POST   /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#create
#        new_rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/new(.:format)                                      rails/conductor/action_mailbox/inbound_emails#new
#            rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#show
# new_rails_conductor_inbound_email_source GET    /rails/conductor/action_mailbox/inbound_emails/sources/new(.:format)                              rails/conductor/action_mailbox/inbound_emails/sources#new
#    rails_conductor_inbound_email_sources POST   /rails/conductor/action_mailbox/inbound_emails/sources(.:format)                                  rails/conductor/action_mailbox/inbound_emails/sources#create
#    rails_conductor_inbound_email_reroute POST   /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                               rails/conductor/action_mailbox/reroutes#create
# rails_conductor_inbound_email_incinerate POST   /rails/conductor/action_mailbox/:inbound_email_id/incinerate(.:format)                            rails/conductor/action_mailbox/incinerates#create
#                       rails_service_blob GET    /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
#                 rails_service_blob_proxy GET    /rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
#                                          GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
#                rails_blob_representation GET    /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
#          rails_blob_representation_proxy GET    /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
#                                          GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
#                       rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
#                update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
#                     rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create
#
# Routes for RailsAdmin::Engine:
#    dashboard GET         /                                       rails_admin/main#dashboard
#        index GET|POST    /:model_name(.:format)                  rails_admin/main#index
#          new GET|POST    /:model_name/new(.:format)              rails_admin/main#new
#       export GET|POST    /:model_name/export(.:format)           rails_admin/main#export
#  bulk_delete POST|DELETE /:model_name/bulk_delete(.:format)      rails_admin/main#bulk_delete
#  bulk_action POST        /:model_name/bulk_action(.:format)      rails_admin/main#bulk_action
#         show GET         /:model_name/:id(.:format)              rails_admin/main#show
#         edit GET|PUT     /:model_name/:id/edit(.:format)         rails_admin/main#edit
#       delete GET|DELETE  /:model_name/:id/delete(.:format)       rails_admin/main#delete
#  show_in_app GET         /:model_name/:id/show_in_app(.:format)  rails_admin/main#show_in_app
# mark_as_done GET|POST    /:model_name/:id/mark_as_done(.:format) rails_admin/main#mark_as_done
