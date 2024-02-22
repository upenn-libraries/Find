# frozen_string_literal: true

module Find
  # Replaces the Blacklight Join step so we can customize how we display multivalued fields
  class JoinProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Context
    include ActionView::Helpers::TextHelper

    def render
      return next_step(values) if values.blank?
      return next_step(values.first) if values.length == 1 && !link_hash?(values.first)

      joined = content_tag :ul, id: "#{config.key}-list", class: list_classes(values).join(' ') do
        values.each do |value|
          list_item = content_tag(:li, format_value(value), class: list_item_classes(value).join(' '))
          concat list_item
        end
      end

      next_step(joined)
    end

    private

    # @param [String] value
    def format_value(value)
      return value unless link_hash?(value)

      content_tag(:a, value[:link_text], href: value[:link_url])
    end

    # @param [String] value
    def link_hash?(value)
      value.instance_of?(Hash) && value.key?(:link_text) && value.key?(:link_url)
    end

    # @param [Array<String>] values
    def list_classes(values)
      classes = ['list-unstyled']
      classes << 'list-group' if link_hash?(values.first)
      classes
    end

    # @param [String] value
    def list_item_classes(value)
      classes = []
      classes << 'list-group-item' if link_hash?(value)
      classes
    end
  end
end
