# frozen_string_literal: true

module Inventory
  class Sort
    # creates objects to sort Alma Availability API inventory data
    class Factory
      # @param inventory_data [Array]
      # returns appropriate Inventory::Sort instance
      def self.create(inventory_data)
        type = inventory_data.first&.dig('inventory_type')
        case type
        when Inventory::Entry::PHYSICAL
          Inventory::Sort::Physical.new(inventory_data)
        when Inventory::Entry::ELECTRONIC
          Inventory::Sort::Electronic.new(inventory_data)
        else
          Inventory::Sort.new(inventory_data)
        end
      end
    end
  end
end
