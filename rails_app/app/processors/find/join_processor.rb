# frozen_string_literal: true

module Find
  # Replaces the Blacklight Join step so we can customize how we display multivalued fields
  class JoinProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Context
    include ActionView::Helpers::TextHelper

    def render
      return next_step(values) if values.blank? || json_request?
      return next_step(values.first) if values.length == 1

      next_step unordered_list_of values
    end

    private

    # @param [Array<String>] values
    # @return [ActiveSupport::SafeBuffer]
    # rubocop:disable Rails/OutputSafety
    def unordered_list_of(values)
      content_tag :ul do
        safe_join(values.filter_map { |value| content_tag(:li, value.html_safe) })
      end
    end
    # rubocop:enable Rails/OutputSafety

    # @return [Boolean]
    def json_request?
      context.search_state.params[:format] == 'json'
    end
  end
end
