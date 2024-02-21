# frozen_string_literal: true

module Find
  # Replaces the Blacklight Join step so we can customize how we display multivalued fields
  class JoinProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Context
    include ActionView::Helpers::TextHelper

    def render
      return next_step(values) if values.blank?
      return next_step(values.first) if values.length == 1

      joined = content_tag :ul, id: "#{config.key}-list", class: 'list-unstyled' do
        values.each do |value|
          list_item = content_tag(:li, format_value(value))
          concat list_item
        end
      end

      next_step(joined)
    end

    private

    def format_value(value)
      return value unless link_hash?(value)

      content_tag(:a, value[:link_text], href: value[:link_url])
    end

    def link_hash?(value)
      value.instance_of?(Hash) && value.key?(:link_text) && value.key?(:link_url)
    end
  end
end
