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
# You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
# <https://www.gnu.org/licenses/>.

# NOTE: only doing this in development as some production environments (Heroku)
# NOTE: are sensitive to local FS writes, and besides -- it's just not proper
# NOTE: to have a dev-mode tool do its thing in production.
if Rails.env.development?
  require "annotate"
  task :set_annotation_options do
    # You can override any of these by setting an environment variable of the
    # same name.
    Annotate.set_defaults(
      "active_admin" => "false",
      "additional_file_patterns" => [],
      "routes" => "true",
      "models" => "true",
      "position_in_routes" => "bottom",
      "position_in_class" => "bottom",
      "position_in_test" => "bottom",
      "position_in_fixture" => "bottom",
      "position_in_factory" => "bottom",
      "position_in_serializer" => "bottom",
      "show_foreign_keys" => "true",
      "show_complete_foreign_keys" => "false",
      "show_indexes" => "true",
      "simple_indexes" => "false",
      "model_dir" => "app/models",
      "root_dir" => "",
      "include_version" => "false",
      "require" => "",
      "exclude_tests" => "false",
      "exclude_fixtures" => "false",
      "exclude_factories" => "false",
      "exclude_serializers" => "false",
      "exclude_scaffolds" => "true",
      "exclude_controllers" => "true",
      "exclude_helpers" => "true",
      "exclude_sti_subclasses" => "false",
      "ignore_model_sub_dir" => "false",
      "ignore_columns" => nil,
      "ignore_routes" => nil,
      "ignore_unknown_models" => "false",
      "hide_limit_column_types" => "integer,bigint,boolean",
      "hide_default_column_types" => "json,jsonb,hstore",
      "skip_on_db_migrate" => "false",
      "format_bare" => "true",
      "format_rdoc" => "false",
      "format_yard" => "false",
      "format_markdown" => "false",
      "sort" => "false",
      "force" => "false",
      "frozen" => "false",
      "classified_sort" => "true",
      "trace" => "false",
      "wrapper_open" => nil,
      "wrapper_close" => nil,
      "with_comment" => "true"
    )
  end

  Annotate.load_tasks

  # Due to https://github.com/ctran/annotate_models/issues/845
  task :routes do
    require "rails/commands/routes/routes_command"
    Rails.application.require_environment!
    cmd = Rails::Command::RoutesCommand.new
    cmd.perform
  end
end
