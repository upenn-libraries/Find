# frozen_string_literal: true

module Catalog
  # DocumentComponent that inherits from Blacklight::DocumentComponent (from Blacklight v9.0) in order to display
  # inventory information and provide other customizations.
  class ResultsDocumentComponent < Blacklight::DocumentComponent
    renders_one :brief_inventory, -> { Inventory::BriefSkeletonComponent.new(document: @document) }

    def before_render
      super
      with_brief_inventory unless brief_inventory
    end
  end
end
