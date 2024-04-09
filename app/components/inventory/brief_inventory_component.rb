# frozen_string_literal: true

module Inventory
  # Component that renders a set of InventoryEntries for use in in filling-in a Turbo Frame.
  class BriefInventoryComponent < ViewComponent::Base
    # @param document[SolrDocument]
    def initialize(document:)
      @id = document.id
      @entries = document.brief_inventory
    end
  end
end
