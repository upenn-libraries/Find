# frozen_string_literal: true

module Inventory
  class List
    module Sort
      # Sorts electronic holdings data retrieved from Alma Availability API call
      class Electronic < Base
        BASE_SCORE = 0

        # Sorts electronic holdings ('portfolios') in descending order using legacy sorting scheme.
        # First sorts using services mapping, breaking any ties by sorting collection name in alphabetical order.
        # @return [Array]
        def sort
          inventory_data.sort_by { |data| [Put.desc(service_score(data)), Put.asc(data['collection'])] }
        end

        private

        # Retrieve maximum score from services mapping. Returns base score if collection and interface are not in
        # services mapping.
        # @param data [Hash] hash from inventory_data array
        # @return [Integer]
        def service_score(data)
          collection = data['collection']
          collection_score = Mappings.electronic_scoring[:collection][collection]
          interface = data['interface_name']
          interface_score = Mappings.electronic_scoring[:interface][interface]

          [collection_score, interface_score].compact.max || BASE_SCORE
        end
      end
    end
  end
end
