# frozen_string_literal: true

module Fulfillment
  module Choices
    # Pickup component logic
    class PickupComponent < BaseComponent
      DEFAULT_PICKUP = 'Van Pelt Library'

      # @return [String]
      def default_pickup_location
        pickup_locations[DEFAULT_PICKUP]
      end

      def delivery_value
        Fulfillment::Options::Deliverable::PICKUP
      end

      def pickup_locations
        @pickup_locations ||= generate_pickup_locations(:ils)
      end
    end
  end
end
