# frozen_string_literal: true

module Inventory
  class List
    module Sort
      # Sorts physical inventory data retrieved from Alma Availability API call
      class Physical < Base
        # Sorts physical inventory in descending order based on the following criteria: availability, priority,
        # location, available items, and coverage statement. In the sort_by block we return an array comprising of
        # values for each of these criteria. Inventory are sorted by comparing these arrays.
        # @return [Array]
        def sort
          inventory_data.sort_by { |data| sort_key_for(UnsortedInventory.new(data)) }
        end

        private

        # Returns an array of sort criteria for a given holding. Ruby compares arrays element-by-element,
        # so each value acts as a tiebreaker when all previous values are equal.
        # The Put DSL wraps criteria in comparable objects: Put.first/last for booleans,
        # Put.asc/desc for values with natural ordering.
        # @param inv [UnsortedInventory]
        # @return [Array]
        def sort_key_for(inv)
          # favor freely-circulating available holdings above all others
          [(Put.first if inv.circulating_available?),
           # favor aeon-requestable holdings second — available but not freely circulating
           (Put.first if inv.aeon_requestable?),
           # do not favor unavailable inventory ('check_holdings' ranks above 'unavailable')
           (Put.last if inv.unavailable?),
           # downrank inventory in configured library locations due to circulation complexity
           (Put.last if inv.undesirable_library?),
           # favor inventory in configured priority library locations (e.g. Van Pelt) to win tiebreaks
           (Put.first if inv.priority_library?),
           # favor inventory with 'higher' priority (lower number = higher priority)
           Put.asc(inv.priority),
           # favor more desirable locations (offsite and unavailable locations receive lower scores)
           Put.desc(inv.location_score),
           # favor inventory with more available items
           Put.desc(inv.available_items),
           # favor items with a coverage statement — ultimate tiebreaker
           (Put.first if inv.coverage_statement?)]
        end

        # Provides a convenient interface to retrieve sorting criteria for unsorted data
        class UnsortedInventory
          # default priority value to use for unprioritized items. This number must be large because lower
          # priority values are ranked higher.
          DEFAULT_PRIORITY = 100

          attr_reader :data

          # @param [Hash] data
          def initialize(data)
            @data = data
          end

          # Returns true for holdings that are available and freely circulating (not Aeon-restricted).
          # These rank above aeon-requestable holdings in the sort.
          # @return [Boolean]
          def circulating_available?
            (data['availability'] == Inventory::Constants::AVAILABLE) && !aeon_location?
          end

          # Returns true for Aeon-location holdings that are not unavailable.
          # These rank below freely-circulating available holdings but above check_holdings/unavailable.
          # @return [Boolean]
          def aeon_requestable?
            aeon_location? && (data['availability'] != Inventory::Constants::UNAVAILABLE)
          end

          # @return [Boolean]
          def unavailable?
            data['availability'] == Inventory::Constants::UNAVAILABLE
          end

          # @return [Boolean]
          def coverage_statement?
            data['coverage_statement'].present?
          end

          # @return [Boolean]
          def undesirable_library?
            data['library_code'].in? Settings.library.undesirable_holdings
          end

          # Returns true for holdings in configured priority libraries (e.g. Van Pelt).
          # Used to break ties between available holdings of equal rank.
          # @return [Boolean]
          def priority_library?
            data['library_code'].in? Settings.library.priority_holdings
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
          def undesirable_location?
            undesirable_locations = Mappings.offsite_locations + Mappings.unavailable_locations
            data['location_code'].in?(undesirable_locations)
          end
        end
      end
    end
  end
end
