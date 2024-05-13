# frozen_string_literal: true

module Account
  # Component that renders a Shelf::Entry on a show page. This component renders all the details about a Shelf::Entry.
  class ShelfEntryComponent < ViewComponent::Base
    attr_reader :entry

    # @param entry [Shelf::Entry]
    def initialize(entry)
      @entry = entry
    end
  end
end
