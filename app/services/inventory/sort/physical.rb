# frozen_string_literal: true

module Inventory
  class Sort
    # Sorts physical holdings data retrieved from Alma Availability API call
    class Physical < Inventory::Sort
      # Sorts physical holdings in descending order based on availability, priority, location, available items, and
      # coverage statement.
      # @return [Array]
      def sort
        holdings.sort_by do |holding|
          unsorted_holding = UnsortedHolding.new(holding)
          [(Put.first if unsorted_holding.available?),
           (Put.last if unsorted_holding.unavailable?),
           Put.asc(unsorted_holding.priority),
           Put.desc(unsorted_holding.location_score),
           Put.desc(unsorted_holding.available_items),
           (Put.first if unsorted_holding.coverage_statement?)]
        end
      end

      # Provides a convenient interface to retrieve sorting criteria for unsorted data
      class UnsortedHolding
        AVAILABLE = 'available'
        UNAVAILABLE = 'unavailable'
        DEFAULT_PRIORITY = 100

        attr_reader :data

        # @param [Hash] data
        def initialize(data)
          @data = data
        end

        # @return[Boolean]
        def available?
          data['availability'] == AVAILABLE
        end

        # @return[Boolean]
        def unavailable?
          data['availability'] == UNAVAILABLE
        end

        # @return[Boolean]
        def coverage_statement?
          data['coverage_statement'].present?
        end

        # @return[Integer]
        def available_items
          data['total_items'].to_i - data['non_available_items'].to_i
        end

        # @return[Integer]
        def priority
          data.fetch('priority', DEFAULT_PRIORITY).to_i
        end

        # @return[Integer]
        def location_score
          Inventory::Sort::LocationScore.score(data)
        end
      end
    end
  end
end
