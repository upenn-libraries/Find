# frozen_string_literal: true

module Inventory
  module Full
    # Renders vertical navigation pane for record show page inventory entries. Uses tab pill nav functionality
    # provided by Bootstrap.
    class NavigationComponent < ViewComponent::Base
      include Turbo::FramesHelper

      attr_reader :inventory

      # @param inventory [Inventory::List::TabCollection]
      # @param selected_id [String] entry id for selected entry
      def initialize(inventory:, selected_id:)
        @inventory = inventory
        @tabs = inventory.tabs
        @selected_id = selected_id
      end

      # Is a passed-in tab currently selected? Used to add 'active' class
      # @param tab [Inventory::List::Tab]
      # @return [Boolean]
      def active?(tab)
        inventory.active?(@selected_id, tab)
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
