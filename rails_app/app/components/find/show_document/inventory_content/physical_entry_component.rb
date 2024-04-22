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

        # @return [String]
        def availability_description
          label_for value: entry.status, field: :description
        end

        private

        # Look up scoped labels in the Alma locale file
        # @param value [String, Symbol]
        # @param field [String, Symbol]
        # @return [String]
        def label_for(value:, field:)
          scope = [:alma, :availability, value.to_sym, :physical]
          I18n.t(field.to_sym, scope: scope)
        end
      end
    end
  end
end
