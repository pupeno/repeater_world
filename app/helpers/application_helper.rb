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

module ApplicationHelper
  # Used to convert environment variables from Ruby to JavaScript.
  def javascript_quoted_string_or_null(val)
    if val.present?
      "\"#{h val}\"".html_safe
    else
      "null"
    end
  end

  def gravatar_url(email)
    "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest email}?d=mp"
  end

  def badge_checkbox(form, name, label)
    render partial: "shared/badge_checkbox",
      locals: {form: form, name: name, label: label}
  end

  def toggle_checkbox(form, name, check_box_html_options)
    render partial: "shared/toggle_checkbox",
      locals: {form: form, name: name,
               check_box_html_options: check_box_html_options}
  end

  def pop_up(title:, links: [], **args, &block)
    render partial: "shared/pop_up",
      locals: {title: title,
               links: links,
               args: args,
               contents: capture(&block)}
  end

  def tabbed_view(tabs:, selected_tab:, &block)
    render partial: "shared/tabbed_view",
      locals: {tabs: tabs,
               selected_tab: selected_tab,
               contents: capture(selected_tab, &block)}
  end

  def dropdown_menu(&block)
    render partial: "shared/dropdown_menu",
      locals: {contents: capture(&block)}
  end

  def badge(content = nil, &block)
    render partial: "shared/badge",
      locals: {contents: content || capture(&block)}
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
