# frozen_string_literal: true

module Find
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