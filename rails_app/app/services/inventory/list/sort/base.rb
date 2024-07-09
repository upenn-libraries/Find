# frozen_string_literal: true

module Inventory
  class List
    # Base class to sort inventory data from Alma Availability API
    module Sort
      class Base
        attr_reader :inventory_data

        # @param inventory_data [Array] inventory data from Alma Availability API
        def initialize(inventory_data)
          @inventory_data = inventory_data
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
  end
end
