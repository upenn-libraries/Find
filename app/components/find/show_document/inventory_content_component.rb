# frozen_string_literal: true

module Find
  module ShowDocument
    class InventoryContentComponent < ViewComponent::Base
      # @param inventory [Hash] inventory data hash
      # @param selected_id [String] entry id for selected entry
      def initialize(inventory:, selected_id:)
        @inventory = inventory
        @selected_id = selected_id
      end

      # Is a passed-in entry currently selected? Used to add 'active' class
      # @param entry [Hash]
      # @return [Boolean]
      def active?(entry)
        @selected_id == entry[:id]
      end

      # @return [Hash]
      def inventory_entries
        @inventory[:inventory]
      end
    end
  end
end
