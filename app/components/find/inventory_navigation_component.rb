# frozen_string_literal: true

module Find
  # Render's vertical navigation pane for record show page inventory entries
  class InventoryNavigationComponent < ViewComponent::Base
    # @param document [SolrDocument] the document being rendered
    # @param params [ActionController::Parameters] parameters from request
    def initialize(document:, params:)
      @inventory = document.inventory
      @document = document
      @params = params
    end

    # Is a passed-in entry currently selected? Used to add 'active' class
    # @param entry [Hash]
    # @return [Boolean]
    def active?(entry)
      # activate the holding specified in the params, if set
      return params[:hld_id] == entry[:id] if @params.key? :hld_id

      # otherwise activate the first holding
      entry[:id] == @inventory.entries.first&.dig(:id)
    end
  end
end
