# frozen_string_literal: true

module Inventory
  # Base class to sort inventory data from Alma Availability API
  class Sort
    attr_reader :inventory_data, :mappings

    # @param inventory_data [Array] inventory data from Alma Availability API
    def initialize(inventory_data, mappings = Inventory::Mappings)
      @inventory_data = inventory_data
      @mappings = mappings
    end

    # Sorting method that subclasses override. We use the Put gem, which doesn't change how sort_by works, but provides
    # readable methods to to use for each sorting criteria/value. These methods return Put::PutsThing objects that
    # share a custom comparator to handle comparing booleans, deal with problematic nil values,
    # and determine sort order (ascending/descending). This default sort method randomizes the inventory.
    # @return [Array]
    def sort
      inventory_data.sort_by { |_data| Put.anywhere }
    end
  end
end
