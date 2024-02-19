# frozen_string_literal: true

module Find
  # Render's vertical navigation pane for record show page inventory entries
  class InventoryNavigationComponent < ViewComponent::Base
    # @param [Array] inventory
    # @param [SolrDocument] document being rendered
    # @param [ActionController::Parameters] params from request
    def initialize(inventory:, document:, params:)
      @inventory = inventory
      @document = document
      @params = params
    end

    # Is a passed-in entry currently selected? Used to add 'active' class
    # @param [Hash] entry
    # @return [Boolean]
    def active?(entry)
      # activate the holding specified in the params, if set
      return params[:hld_id] == entry[:id] if @params.key? :hld_id

      # otherwise activate the first holding
      entry[:id] == inventory_entries.first&.dig(:id)
    end

    # @return [Hash]
    def inventory_entries
      @inventory[:inventory]
    end
  end
end
