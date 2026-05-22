# frozen_string_literal: true

# Base helper for application views
module ApplicationHelper
  # @return [Boolean]
  def render_clarity_script?
    Settings.ms_clarity&.id.present?
  end
end
