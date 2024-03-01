# frozen_string_literal: true

module Find
  module ShowDocument
    # Renders tab content for all inventory entries. Uses Bootstrap's tab functionality.
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
        @selected_id == entry.id
      end

      def render_entry(entry)
        component_class = "Find::ShowDocument::InventoryContent::#{entry.type.camelize}EntryComponent".constantize
        render(component_class.new(entry: entry))
      end
    end
  end
end
