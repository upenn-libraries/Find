# frozen_string_literal: true

# Copied from Blacklight v9.0

module Catalog
  # For rendering "Find it" rather than Blacklight's icon with a hidden label
  # A label comes with more affordances such as being able to select the control
  # with voice when an icon could be difficult to know how to target.
  class SearchButtonComponent < Blacklight::Component
    def initialize(text:, id:)
      @text = text
      @id = id
    end

    def call
      tag.button(@text, class: button_classes, type: 'submit', id: @id)
    end

    private

    # @return [String]
    def button_classes
      'pl-button pl-button--accent pl-padding-y-xs pl-padding-x-m pl-border-radius pl-font-size-m search-btn'
    end
  end
end
