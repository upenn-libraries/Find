# frozen_string_literal: true

module Catalog
  # DocumentComponent that inherits from Blacklight::DocumentComponent in order to display
  # inventory information and provide other customizations.
  class ShowDocumentComponent < Blacklight::DocumentComponent
    renders_one :inventory_navigation, lambda {
      Inventory::Full::NavigationComponent.new(inventory: @inventory, selected_id: @selected_id)
    }

    renders_one :inventory_content, lambda {
      Inventory::Full::ContentComponent.new(inventory: @inventory, selected_id: @selected_id, user: @user)
    }

    # @option params [ActionController::Parameters] parameters from request
    def initialize(**args)
      super
      @inventory = @document.full_inventory
      @selected_id = args[:params][:hld_id] || @inventory.first&.id
      @user = args[:user]
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
