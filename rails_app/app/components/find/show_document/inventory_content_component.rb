# frozen_string_literal: true

module Find
  module ShowDocument
    # Renders tab content for all inventory entries. Uses Bootstrap's tab functionality.
    class InventoryContentComponent < ViewComponent::Base
      # @param inventory [Inventory::Response] inventory response
      # @param selected_id [String] entry id for selected entry
      def initialize(inventory:, selected_id:)
        @inventory = inventory
        @selected_id = selected_id
      end

      # Is a passed-in entry currently selected? Used to add 'active' class
      # @param entry [Inventory::Entry] inventory entry
      # @return [Boolean]
      def active?(entry)
        @selected_id == entry.id
      end

      def render_entry(entry)
        type = entry.class.name.split('::').last
        component_class = "Find::ShowDocument::InventoryContent::#{type}EntryComponent".constantize
        render(component_class.new(entry: entry))
      end
    end
  end
end
