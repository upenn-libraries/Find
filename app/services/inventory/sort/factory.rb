# frozen_string_literal: true

module Inventory
  class Sort
    # creates objects to sort Alma Availability API inventory data
    class Factory
      # @param inventory_data [Array]
      # @param mappings [Class<Inventory::Mappings>]
      # returns appropriate Inventory::Sort instance
      def self.create(inventory_data, mappings = Inventory::Mappings)
        type = inventory_data.first&.dig('inventory_type')
        case type
        when Inventory::Entry::PHYSICAL
          Inventory::Sort::Physical.new(inventory_data, mappings)
        when Inventory::Entry::ELECTRONIC
          Inventory::Sort::Electronic.new(inventory_data, mappings)
        else
          Inventory::Sort.new(inventory_data, mappings)
        end
      end
    end
  end
end
