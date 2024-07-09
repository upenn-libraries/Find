# frozen_string_literal: true

module Inventory
  class List
    module Sort
      # Sorts physical inventory data retrieved from Alma Availability API call
      class Physical < Base
        # Sorts physical inventory in descending order based on the following criteria: availability, priority, location,
        # available items, and coverage statement. In the sort_by block we return an array comprising of values for each
        # of these criteria. Inventory are sorted by comparing these arrays.
        # @return [Array]
        def sort
          inventory_data.sort_by do |data|
            unsorted_inventory = UnsortedInventory.new(data)
            # The Put DSL wraps each criteria value in a Put::PutThings object for convenience. We can use Put.first
            # and Put.last to convert boolean values into values that can be compared. On the other hand,
            # Put.asc  and Put.desc handles values that have their own comparators such as Integers or Strings.

            # When Ruby compares arrays, each element in the array is compared to the other corresponding element,
            # and as soon as a comparison returns an unequal result, that result is returned for the entire
            # array comparison. This means we can think of each value in the array as a kind of 'tie breaker' if the
            # previous elements were equal during a comparison.

            # When sorting physical inventory, we:

            # favor inventory deemed available, that is inventory with an available status or inventory requestable
            # through aeon
            [(Put.first if unsorted_inventory.available?),
             # do not favor unavailable inventory, in practice this means ranking a 'check_holdings' status higher than
             # 'unavailable'
             (Put.last if unsorted_inventory.unavailable?),
             # favor inventory with 'higher' priority, we use an ascending order here because a lower number
             # denotes a higher priority
             Put.asc(unsorted_inventory.priority),
             # favor items with more desirable locations - we lower the score of offsite locations and greatly lower the
             # score of unavailable locations, all other locations receive the same base score
             Put.desc(unsorted_inventory.location_score),
             # favor inventory with more available items
             Put.desc(unsorted_inventory.available_items),
             # favor items with coverage statement. This is the ultimate 'tie-breaker' if all the previous values
             # are equal
             (Put.first if unsorted_inventory.coverage_statement?)]
          end
        end

        # Provides a convenient interface to retrieve sorting criteria for unsorted data
        class UnsortedInventory
          # default priority value to use for unprioritized items. This number must be large because lower priority values
          # are ranked higher.
          DEFAULT_PRIORITY = 100

          attr_reader :data

          # @param [Hash] data
          def initialize(data)
            @data = data
          end

          # @return [Boolean]
          def available?
            (data['availability'] == Inventory::Constants::AVAILABLE) || aeon_requestable?
          end

          # @return [Boolean]
          def unavailable?
            data['availability'] == Inventory::Constants::UNAVAILABLE
          end

          # @return [Boolean]
          def coverage_statement?
            data['coverage_statement'].present?
          end

          # @return[Integer]
          def available_items
            data['total_items'].to_i - data['non_available_items'].to_i
          end

          # Retrieve priority while accounting for undesirable locations
          # @return [Integer]
          def priority
            return DEFAULT_PRIORITY if undesirable_location?

            data.fetch('priority', DEFAULT_PRIORITY).to_i
          end

          # @return [Integer]
          def location_score
            Inventory::List::Sort::LocationScore.score(data)
          end

          private

          # @return [Boolean]
          def aeon_location?
            data['location_code'].in?(Mappings.aeon_locations)
          end

          # @return [Boolean]
          def aeon_requestable?
            aeon_location? && (data['availability'] != Inventory::Constants::UNAVAILABLE)
          end

          # @return [Boolean]
          def undesirable_location?
            undesirable_locations = Mappings.offsite_locations + Mappings.unavailable_locations
            data['location_code'].in?(undesirable_locations)
          end
        end
      end
    end
  end
end

