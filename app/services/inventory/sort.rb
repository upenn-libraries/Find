# frozen_string_literal: true

module Inventory
  # Base class to sort holdings from Alma Availability API
  class Sort
    attr_reader :holdings

    # @param [Array] holdings
    def initialize(holdings)
      @holdings = holdings
    end

    # sorting method that subclasses override
    # @return [Array]
    def sort
      holdings.sort_by { |_holding| Put.anywhere }
    end
  end
end
