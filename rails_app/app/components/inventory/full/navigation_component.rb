# frozen_string_literal: true

module Inventory
  module Full
    # Renders vertical navigation pane for record show page inventory entries. Uses tab pill nav functionality
    # provided by Bootstrap.
    class NavigationComponent < ViewComponent::Base
      include Turbo::FramesHelper

      # @param inventory [Inventory::Response] inventory response object
      # @param selected_id [String] entry id for selected entry
      def initialize(inventory:, selected_id:, document:)
        @inventory = inventory
        @selected_id = selected_id
        @document = document
      end

      # Is a passed-in entry currently selected? Used to add 'active' class
      # @param entry [Inventory::Entry]
      # @return [Boolean]
      def active?(entry)
        @selected_id == entry.id
      end

      # Classes to use in rendering the inventory entry element
      # @return [Array<String (frozen)>]
      def classes(entry)
        classes = ['inventory-item']
        classes << if entry.status == Inventory::Constants::AVAILABLE || !entry.physical?
                     'inventory-item__availability--easy'
                   elsif entry.status == Inventory::Constants::UNAVAILABLE
                     'inventory-item__availability--difficult'
                   else
                     'inventory-item__availability'
                   end
      end
    end
  end
end
