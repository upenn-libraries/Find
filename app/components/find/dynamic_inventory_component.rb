# frozen_string_literal: true

module Find
  # Component that renders a set of InventoryEntries for use in in filling-in a Turbo Frame.
  class DynamicInventoryComponent < ViewComponent::Base
    # @param document[SolrDocument]
    def initialize(document:)
      @id = document.id
      @entries = document.brief_inventory
    end
  end
end
