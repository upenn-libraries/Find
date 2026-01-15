# frozen_string_literal: true

module Fulfillment
  module Choices
    # ILL Pickup component logic
    class IllPickupComponent < PickupComponent
      def delivery_value
        Fulfillment::Options::Deliverable::ILL_PICKUP
      end
    end
  end
end
