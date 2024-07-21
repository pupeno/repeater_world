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

# TODO: move this to its own file.
module RepeaterWorld
  module Admin
    module Actions
      class MarkAsDone < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option(:member) { true }
        register_instance_option(:pjax?) { true }
        register_instance_option(:bulkable?) { true }
        register_instance_option(:link_icon) { "fa-solid fa-check" }
        register_instance_option(:http_methods) do
          # I could not find a way to have Rails Admin generate icon/buttons for a post action, I don't think it can, so
          # :get is actually modifying the record, which isn't great. TODO: improve this?
          [:get, :post]
        end

        register_instance_option(:controller) {
          ->(_rails_admin) {
            @object.done_at = Time.now.utc
            @object.save!
            redirect_to_on_success
          }
        }
      end
    end

    module ControllerExtension
      def user_for_paper_trail
        # This line, as provided by rails_admin, looks like this:
        #    _current_user.try(:id) || _current_user
        # but we don't want to save the id of a user, we want to save the global id, so we need to just pass the active
        # record object to paper trail and let the global id deal with it.
        # https://github.com/railsadminteam/rails_admin/blob/afee74e4fb7cb0b2ec0168475ae6ee606cdf02c5/lib/rails_admin/extensions/paper_trail/auditing_adapter.rb#L42
        current_admin
      end
    end
  end
end

RailsAdmin.config do |config|
  config.main_app_name = ["Repeater World", "Admin"]

  config.asset_source = :sprockets

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :admin
  end
  config.current_user_method(&:current_admin)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  config.audit_with :paper_trail, "Admin", "PaperTrail::Version"
  RailsAdmin::Extensions::ControllerExtension.include RepeaterWorld::Admin::ControllerExtension

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard # mandatory
    index # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show

    mark_as_done do
      only ["SuggestedRepeater"]
    end

    auditable_models = ["Repeater"]
    history_index do
      only auditable_models
    end
    history_show do
      only auditable_models
    end
  end

  config.label_methods << :to_s
end

# Add Rails Admin support for the "geography" column type
# https://github.com/railsadminteam/rails_admin/issues/2225
class RailsAdmin::Config::Fields::Types::Geography < RailsAdmin::Config::Fields::Base
  RailsAdmin::Config::Fields::Types.register(self)

  # Add some sensible default behaviour. Can be overridden when
  # configuring models/fields

  register_instance_option :read_only? do
    true
  end

  register_instance_option :sortable do
    false
  end

  register_instance_option :searchable do
    false
  end

  register_instance_option :queryable? do
    false
  end

  register_instance_option :filterable? do
    false
  end
end
