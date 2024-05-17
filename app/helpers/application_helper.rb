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

module ApplicationHelper
  # Used to convert environment variables from Ruby to JavaScript.
  def javascript_quoted_string_or_null(val)
    if val.present?
      "\"#{h val}\"".html_safe
    else
      "null"
    end
  end

  def pop_up(title:, links: [], **args, &)
    render partial: "shared/pop_up",
      locals: {title: title,
               links: links,
               args: args,
               contents: capture(&)}
  end

  def tabbed_view(tabs:, selected_tab:, &)
    render partial: "shared/tabbed_view",
      locals: {tabs: tabs,
               selected_tab: selected_tab,
               contents: capture(selected_tab, &)}
  end

  def dropdown_menu(&)
    render partial: "shared/dropdown_menu",
      locals: {contents: capture(&)}
  end

  def badge(content = nil, &)
    render partial: "shared/badge",
      locals: {contents: content || capture(&)}
  end

  def card_entry(label:, value: nil, optional: false, &block)
    if optional && value.blank?
      return
    end
    if value.in? [true, false]
      value = render partial: "shared/card/boolean", locals: {value: value}
    end
    render partial: "shared/card/entry",
      locals: {label: label,
               contents: block ? capture(&block) : value}
  end
end
