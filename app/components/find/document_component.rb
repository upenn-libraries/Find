# frozen_string_literal: true

module Find
  # DocumentComponent that inherits from Blacklight::DocumentComponent in order to display
  # availability information and provide other customizations.
  class DocumentComponent < Blacklight::DocumentComponent
    renders_one :availability, -> { Find::AvailabilityComponent.new(document: @document, brief: !@show, lazy: true) }

    def before_render
      super
      set_slot(:availability, nil) unless availability
    end
  end
end
