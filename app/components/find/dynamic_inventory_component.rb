# frozen_string_literal: true

module Find
  # Component that renders a set of InventoryEntries for use in in filling-in a Turbo Frame.
  class DynamicInventoryComponent < ViewComponent::Base
    # @param id [String]
    # @param [Hash] entries
    def initialize(id:, entries:)
      @id = id
      @entries = entries
    end
  end
end
