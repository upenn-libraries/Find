# frozen_string_literal: true

module Inventory
  class List
    module Sort
      # Provides a sortable value for the locations of physical inventory
      class LocationScore
        BASE_SCORE = 0
        OFFSITE_SCORE = - 1
        UNAVAILABLE_SCORE = -2
        MAP = [{ locations: Mappings.offsite_locations, score: OFFSITE_SCORE },
               { locations: Mappings.unavailable_locations,
                 score: UNAVAILABLE_SCORE }].freeze
        class << self
          # @return [Integer]
          # First checks if the location is offsite or unavailable, and returns the corresponding low score.
          # If inventory is located in neither of these less desirable locations they receive the higher base score.
          # We score unavailable locations the least, offsite locations the second least, and all other locations
          # receive an equally high base score.
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
end
