# frozen_string_literal: true

# Copied from Blacklight v8.10.1

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
      tag.button(@text, class: 'btn btn-primary search-btn', type: 'submit', id: @id)
    end
  end
end
