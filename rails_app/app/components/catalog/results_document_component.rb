# frozen_string_literal: true

module Catalog
  # DocumentComponent that inherits from Blacklight::DocumentComponent (from v8.10.1) in order to display
  # inventory information and provide other customizations.
  class ResultsDocumentComponent < Blacklight::DocumentComponent
    renders_one :brief_inventory, -> { Inventory::BriefSkeletonComponent.new(document: @document) }

    def before_render
      super
      set_slot(:brief_inventory, nil) unless brief_inventory
    end
  end
end
