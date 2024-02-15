# frozen_string_literal: true

module Find
  # Component that displays a set of InventoryEntries for a given record.
  class InventoryEntriesComponent < ViewComponent::Base
    # @param [String] id
    # @param [Hash] entries
    def initialize(id:, entries:)
      @id = id
      @entries = entries
    end
  end
end
