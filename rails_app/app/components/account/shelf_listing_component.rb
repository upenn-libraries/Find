# frozen_string_literal: true

module Account
  # Component that renders a Shelf::Listing containing many entries.
  class ShelfListingComponent < ViewComponent::Base
    # @param listing [Shelf::Listing]
    def initialize(listing)
      @listing = listing
    end
  end
end
