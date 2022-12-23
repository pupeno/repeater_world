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
           locals: { form: form, name: name, label: label }
  end

  def toggle_checkbox(form, name, check_box_html_options)
    render partial: "shared/toggle_checkbox",
           locals: { form: form, name: name,
                     check_box_html_options: check_box_html_options }
  end

  def pop_up(title:, triggering_event:, links:, **args, &block)
    render partial: "shared/pop_up",
           locals: { title: title,
                     triggering_event: triggering_event,
                     links: links,
                     args: args,
                     contents: capture(&block) }
  end
end
