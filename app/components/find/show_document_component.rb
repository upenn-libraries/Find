# frozen_string_literal: true

module Find
  # DocumentComponent that inherits from Blacklight::DocumentComponent in order to display
  # inventory information and provide other customizations.
  class ShowDocumentComponent < Blacklight::DocumentComponent
    renders_one :inventory_navigation, lambda {
      Find::InventoryNavigationComponent.new(inventory: @inventory, document: @document, params: @params)
    }

    # @option [Array] inventory used to render InventoryNavigationComponent
    # @option [ActionController::Parameters] params from request
    def initialize(document_counter: nil, **args)
      super
      @inventory = args[:inventory]
      @params = args[:params]
    end

    # @return [Array] classes to use for component element
    def classes
      super.append('col-lg-9')
    end

    # @return [String] inventory id to use when rendering detailed inventory info
    def selected_inventory_id
      @params[:hld_id] || @inventory[:inventory].first&.dig(:id)
    end

    def before_render
      super
      set_slot(:inventory_navigation, nil) unless inventory_navigation
    end
  end
end
