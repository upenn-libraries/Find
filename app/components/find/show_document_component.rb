# frozen_string_literal: true

module Find
  # DocumentComponent that inherits from Blacklight::DocumentComponent in order to display
  # inventory information and provide other customizations.
  class ShowDocumentComponent < Blacklight::DocumentComponent
    renders_one :inventory_navigation, lambda {
      Find::ShowDocument::InventoryNavigationComponent.new(inventory: @inventory, selected_id: @selected_id)
    }

    renders_one :inventory_content, lambda {
      Find::ShowDocument::InventoryContentComponent.new(inventory: @inventory, selected_id: @selected_id)
    }

    # @option inventory [Array] inventory data used to render InventoryNavigationComponent
    # @option params [ActionController::Parameters] parameters from request
    def initialize(document_counter: nil, **args)
      super
      @inventory = args[:inventory]
      @selected_id = args[:params][:hld_id] || @inventory[:inventory].first&.dig(:id)
    end

    # @return [Array] classes to use for component element
    def classes
      super.append('col-lg-9')
    end

    def before_render
      super
      set_slot(:inventory_navigation, nil) unless inventory_navigation
      set_slot(:inventory_content, nil) unless inventory_content
    end
  end
end
