# frozen_string_literal: true

module Inventory
  module Full
    # Renders tab content for all inventory entries. Uses Bootstrap's tab functionality.
    class ContentComponent < ViewComponent::Base
      attr_accessor :user

      # @param inventory [Inventory::Response] inventory response
      # @param selected_id [String] entry id for selected entry
      # @param user [User] current user
      def initialize(inventory:, selected_id:, user: nil)
        @inventory = inventory
        @selected_id = selected_id
        @user = user
      end

      # Is a passed-in entry currently selected? Used to add 'active' class
      # @param entry [Inventory::Entry] inventory entry
      # @return [Boolean]
      def active?(entry)
        @selected_id == entry.id
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
