# frozen_string_literal: true

module Inventory
  class Sort
    # Provides a sortable value for the locations of physical inventory
    class LocationScore
      BASE_SCORE = 0
      DECREMENT = -1
      MULTIPLIER = 2
      MAP = [{ locations: Inventory::Mappings.offsite_locations, score: DECREMENT },
             { locations: Inventory::Mappings.unavailable_locations,
               score: DECREMENT * MULTIPLIER }].freeze
      class << self
        # @return [Integer]
        # returns a number value that maps onto a location.
        def score(inventory)
          MAP.each do |locations|
            score = score_for_locations(inventory, locations[:locations], locations[:score])
            return score if score.nonzero?
          end
          BASE_SCORE
        end

        private

        # @return [Integer]
        def score_for_locations(inventory, locations, score)
          return BASE_SCORE unless inventory['location_code'].in?(locations)

          score
        end
      end
    end
  end
end
