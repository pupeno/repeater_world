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

module FormHelper
  def form_text_field(form:, field_name:, label: nil, input_html_options: {}, help_text: nil)
    render partial: "shared/forms/text_field",
      locals: {form: form,
               field_name: field_name,
               label: label,
               input_html_options: input_html_options,
               help_text: help_text}
  end

  def form_email_field(form:, field_name:, label: nil, input_html_options: {}, help_text: nil)
    render partial: "shared/forms/email_field",
      locals: {form: form,
               field_name: field_name,
               label: label,
               input_html_options: input_html_options,
               help_text: help_text}
  end

  def form_textarea_field(form:, field_name:, label: nil, input_html_options: {}, help_text: nil)
    render partial: "shared/forms/textarea_field",
      locals: {form: form,
               field_name: field_name,
               label: label,
               input_html_options: input_html_options,
               help_text: help_text}
  end
end
