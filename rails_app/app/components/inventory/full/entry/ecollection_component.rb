# frozen_string_literal: true

module Inventory
  module Full
    module Entry
      # Component rendering the full view of a Ecollection entry.
      class EcollectionComponent < ViewComponent::Base
        attr_reader :entry

        # @param entry [Inventory::Entry]
        def initialize(entry:)
          @entry = entry
        end
      end
    end
  end
end
