# frozen_string_literal: true

module Find
  # Replaces the Blacklight Join step so we can customize how we display multivalued fields
  class JoinProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Context
    include ActionView::Helpers::TextHelper

    def render
      return next_step(values) if values.blank?
      return next_step(values.first) if values.length == 1

      # rubocop:disable Rails/OutputSafety
      list = content_tag :ul do
        safe_join(values.filter_map { |value| content_tag(:li, value.html_safe) })
      end
      # rubocop:enable Rails/OutputSafety

      next_step list
    end
  end
end
