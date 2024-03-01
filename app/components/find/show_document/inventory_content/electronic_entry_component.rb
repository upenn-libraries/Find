# frozen_string_literal: true

module Find
  module ShowDocument
    module InventoryContent
      # Component rendering the full view of a Electronic entry.
      class ElectronicEntryComponent < ViewComponent::Base
        attr_reader :entry, :include_details

        # @param entry [Inventory::Entry]
        def initialize(entry:)
          @entry = entry
        end
      end
    end
  end
end
