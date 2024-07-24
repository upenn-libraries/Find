# frozen_string_literal: true

module Inventory
  class List
    module Sort
      # creates objects to sort Alma Availability API inventory data
      class Factory
        # @param inventory_data [Array, NilClass]
        # returns appropriate Inventory::Sort instance
        def self.create(inventory_data)
          type = inventory_data&.first&.dig('inventory_type')
          case type
          when List::PHYSICAL then Sort::Physical.new(inventory_data)
          when List::ELECTRONIC, List::ECOLLECTION
            Sort::Electronic.new(inventory_data)
          else
            Sort::Base.new(Array.wrap(inventory_data))
          end
        end
      end
    end
  end
end
