# frozen_string_literal: true

module Account
  # Component that renders a Shelf::Entry in the context of a Shelf::Listing. This displays a brief
  # view of a Shelf::Entry.
  class ShelfListingEntryComponent < ViewComponent::Base
    attr_reader :entry, :index

    # @param entry [Shelf::Entry]
    # @param index [Integer]
    def initialize(entry, index)
      @entry = entry
      @index = index
    end
  end
end
