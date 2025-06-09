module ApplicationHelper
  def form_error_notification(object)
    if object.errors.any?
      tag.p class: "error-message" do
        object.errors.full_messages.to_sentence.capitalize
      end
    end
  end

  def field_errors(object, field)
    return unless object.errors[field].any?

    object.errors.full_messages_for(field).map { |msg| tag.p msg, class: "error-message" }.join.html_safe
  end

  def render_icon(icon, classes: nil)
    classes ||= ""
    render "icons/#{icon}", classes: classes
  end

  def sidebar_link_to(name, path, options = {})
    active_class = current_page?(path) ? "active" : ""
    options[:class] = [ options[:class], active_class ].compact.join(" ")
    link_to name, path, options
  end
end
