# frozen_string_literal: true

module Find
  # DocumentComponent that inherits from Blacklight::DocumentComponent in order to display
  # inventory information and provide other customizations.
  class ResultsDocumentComponent < Blacklight::DocumentComponent
    renders_one :brief_inventory, -> { Find::BriefInventoryComponent.new(document: @document) }

    def before_render
      super
      set_slot(:brief_inventory, nil) unless brief_inventory
    end
  end
end
