module ApplicationHelper
  # Used to convert environment variables from Ruby to JavaScript.
  def javascript_quoted_string_or_null(val)
    if val.present?
      "\"#{h val}\"".html_safe
    else
      "null"
    end
  end
end
