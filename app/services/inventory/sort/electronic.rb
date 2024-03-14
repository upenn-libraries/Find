# frozen_string_literal: true

module Inventory
  class Sort
    # Sorts electronic holdings data retrieved from Alma Availability API call
    class Electronic < Inventory::Sort
      # Sorts electronic holdings ('portfolios') in descending order
      # @return [Array]
      def sort
        holdings
      end
    end
  end
end
