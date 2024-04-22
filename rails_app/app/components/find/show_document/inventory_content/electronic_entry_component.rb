# frozen_string_literal: true

module Find
  module ShowDocument
    module InventoryContent
      # Component rendering the full view of an Electronic entry.
      class ElectronicEntryComponent < ViewComponent::Base
        attr_reader :entry

        # @param entry [Inventory::Entry]
        def initialize(entry:)
          @entry = entry
        end

        # Additional details should only be displayed if both and id and a collection_id is present.
        def additional_details?
          entry.id && entry.collection_id
        end
      end
    end
  end
end
