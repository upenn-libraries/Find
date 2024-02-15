# frozen_string_literal: true

module Find
  # DocumentComponent that inherits from Blacklight::DocumentComponent in order to display
  # inventory information and provide other customizations.
  class DocumentComponent < Blacklight::DocumentComponent
    renders_one :inventory, lambda {
      Find::InventoryComponent.new(
        record_id: @document.id, count: @document.inventory_count, document: @document
      )
    }

    def before_render
      super
      set_slot(:inventory, nil) unless inventory
    end
  end
end
