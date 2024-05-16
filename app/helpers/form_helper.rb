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

module FormHelper
  def form_text_field(form, field_name, label: nil, input_html_options: {}, help_text: nil, wrapper_html_options: {})
    render partial: "shared/forms/text_field",
      locals: {form: form,
               field_name: field_name,
               label: label,
               input_html_options: input_html_options,
               help_text: help_text,
               wrapper_html_options: wrapper_html_options}
  end

  def form_email_field(form, field_name, label: nil, input_html_options: {}, help_text: nil)
    render partial: "shared/forms/email_field",
      locals: {form: form,
               field_name: field_name,
               label: label,
               input_html_options: input_html_options,
               help_text: help_text}
  end

  def form_textarea_field(form, field_name, label: nil, input_html_options: {}, help_text: nil)
    render partial: "shared/forms/textarea_field",
      locals: {form: form,
               field_name: field_name,
               label: label,
               input_html_options: input_html_options,
               help_text: help_text}
  end

  def form_boolean_field(form, field_name, label: nil, second_label: nil, input_html_options: {}, help_text: nil)
    render partial: "shared/forms/boolean_field",
      locals: {form: form,
               field_name: field_name,
               label: label,
               second_label: second_label,
               input_html_options: input_html_options,
               help_text: help_text}
  end

  def form_multi_boolean_field(form, label: nil, fields: [], help_text: nil)
    render partial: "shared/forms/multi_boolean_field",
      locals: {form: form,
               label: label,
               fields: fields,
               help_text: help_text}
  end

  def form_select_field(form, field_name, choices:, options: {}, label: nil, input_html_options: {}, help_text: nil)
    render partial: "shared/forms/select_field",
      locals: {form: form,
               field_name: field_name,
               label: label,
               choices: choices,
               options: options,
               input_html_options: input_html_options,
               help_text: help_text}
  end

  def toggle_button(form, name, label, **kwargs)
    klass = kwargs.delete(:class) || ""
    data = kwargs.delete(:data) || {}
    render partial: "shared/forms/toggle_button",
      locals: {form: form, name: name, label: label, class: klass, data: data, kwargs: kwargs}
  end

  def toggle_like_button(label, checked: true, **kwargs)
    klass = kwargs.delete(:class) || ""
    render partial: "shared/forms/toggle_like_button",
      locals: {label: label, checked: checked, class: klass, kwargs: kwargs}
  end
end
