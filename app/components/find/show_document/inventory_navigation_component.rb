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

      # User-friendly display value for inventory entry status
      # @return [String] status
      def status_for(entry)
        if entry.status == Inventory::Constants::CHECK_HOLDINGS
          return I18n.t('alma.availability.check_holdings.physical.status')
        end
        return I18n.t('alma.availability.unavailable.physical.status') unless available?
        return I18n.t('alma.availability.available.electronic.status') if available? && !physical?
        return I18n.t('alma.availability.available.physical.status') if available? && physical?

        entry.status.capitalize
      end
    end
  end
end
