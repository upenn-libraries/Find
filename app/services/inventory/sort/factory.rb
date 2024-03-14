# frozen_string_literal: true

module Inventory
  class Sort
    # creates objects to sort Alma Availability API holdings data
    class Factory
      class Error < StandardError; end

      # returns appropriate Inventory::Sort instance
      def self.create(holdings)
        type = holdings.first&.dig('inventory_type')
        case type
        when Inventory::Entry::PHYSICAL
          Inventory::Sort::Physical.new(holdings)
        when Inventory::Entry::ELECTRONIC
          Inventory::Sort::Electronic.new(holdings)
        else
          Inventory::Sort.new(holdings)
        end
      end
    end
  end
end
