# frozen_string_literal: true

module Find
  module ShowDocument
    # Renders vertical navigation pane for record show page inventory entries. Uses tab pill nav functionality
    # provided by Bootstrap.
    class InventoryNavigationComponent < ViewComponent::Base
      # @param inventory [Inventory::Response] inventory response object
      # @param selected_id [String] entry id for selected entry
      def initialize(inventory:, selected_id:)
        @inventory = inventory
        @selected_id = selected_id
      end

      # Is a passed-in entry currently selected? Used to add 'active' class
      # @param entry [Inventory::Entry]
      # @return [Boolean]
      def active?(entry)
        @selected_id == entry.id
      end
    end
  end
end
