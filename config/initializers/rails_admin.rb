# Copyright 2023, Flexpoint Tech
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Foobar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with Foobar. If not, see
# <https://www.gnu.org/licenses/>.

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
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

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
