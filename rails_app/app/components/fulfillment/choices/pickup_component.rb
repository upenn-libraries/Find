# frozen_string_literal: true

module Fulfillment
  module Choices
    # Pickup component logic
    class PickupComponent < BaseComponent
      DEFAULT_PICKUP = 'Van Pelt Library'

      def radio_label_content
        t('requests.form.options.pickup.label')
      end

      # @return [String]
      def default_pickup_location
        pickup_locations[DEFAULT_PICKUP]
      end

      # Since this component is used both on the record page and the ILL form, we need to know the right pickup value
      # to include so the right fulfillment endpoint is used.
      # @return [Symbol]
      def delivery_value
        @ill ? Fulfillment::Options::Deliverable::ILL_PICKUP : Fulfillment::Options::Deliverable::PICKUP
      end

      def pickup_locations
        @pickup_locations ||= generate_pickup_locations
      end

      private

      def generate_pickup_locations
        locations = Settings.locations.pickup.to_h
        locations.transform_keys(&:to_s) # Transform keys to strings
                 .transform_values { |v| @ill ? v[:ill] : v[:ils] } # Retrieve code based on type of pickup request
                 .reject { |_, v| v.blank? } # Remove any locations that don't have codes
      end
    end
  end
end
