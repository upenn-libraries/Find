# frozen_string_literal: true

module Inventory
  # Component for rendering physical (holding) detail information (notes)
  class PhysicalDetailComponent < ViewComponent::Base
    attr_accessor :holding

    delegate :notes, to: :holding

    def initialize(holding:)
      @holding = holding
    end

    def formatted_notes
      sanitize(notes.join(' '))
    end
  end
end
