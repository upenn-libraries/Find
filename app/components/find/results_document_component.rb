# frozen_string_literal: true

module Find
  # DocumentComponent that inherits from Blacklight::DocumentComponent in order to display
  # inventory information and provide other customizations.
  class ResultsDocumentComponent < Blacklight::DocumentComponent
    renders_one :brief_inventory, lambda {
      Find::BriefInventoryComponent.new(
        record_id: @document.id, count: @document.inventory_count, document: @document
      )
    }

    def before_render
      super
      set_slot(:brief_inventory, nil) unless brief_inventory
    end

    def brief_count

    end
  end
end
