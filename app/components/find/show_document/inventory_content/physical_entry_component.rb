# frozen_string_literal: true

module Find
  module ShowDocument
    module InventoryContent
      # Component rendering the full view of a Physical entry.
      class PhysicalEntryComponent < ViewComponent::Base
        attr_reader :entry

        # @param entry [Inventory::Entry]
        def initialize(entry:)
          @entry = entry
        end
      end
    end
  end
end
