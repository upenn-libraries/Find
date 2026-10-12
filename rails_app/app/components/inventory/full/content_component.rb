# frozen_string_literal: true

module Inventory
  module Full
    # Renders tab content for all inventory entries. Uses Bootstrap's tab functionality.
    class ContentComponent < ViewComponent::Base
      attr_accessor :user, :inventory

      # @param inventory [Inventory::List::TabCollection]
      # @param selected_id [String] entry id for selected entry
      # @param user [User] current user
      def initialize(inventory:, selected_id:, user: nil)
        @inventory = inventory
        @tabs = inventory.tabs
        @selected_id = selected_id
        @user = user
      end

      # Is a passed-in tab currently selected? Used to add 'active' class
      # @param tab [Inventory::List::Tab]
      # @return [Boolean]
      def active?(tab)
        inventory.active?(@selected_id, tab)
      end

      # Render the appropriate entry component based on the entry type
      # @param entry [Inventory::Entry] inventory entry
      # @return [ActionView::OutputBuffer] HTML content for entry component
      def render_entry(entry)
        type = entry.class.name.split('::').last
        component_class = "Inventory::Full::Entry::#{type}Component".constantize

        if type == 'Physical'
          render(component_class.new(entry: entry, user: user))
        else
          render(component_class.new(entry: entry))
        end
      end
    end
  end
end
