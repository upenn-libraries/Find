# frozen_string_literal: true

module Fulfillment
  module Choices
    # Pickup component logic
    class PickupComponent < ViewComponent::Base
      DEFAULT_STUDENT_PICKUP = 'Lockers at Van Pelt Library'
      DEFAULT_PICKUP = 'Van Pelt Library'

      attr_accessor :user, :checked, :radio_options

      def initialize(user:, ill: false, checked: false, **radio_options)
        @user = user
        @checked = checked
        @ill = ill
        @radio_options = radio_options
      end

      # @return [String]
      def default_pickup_location
        return pickup_locations[DEFAULT_STUDENT_PICKUP] if user.student?

        pickup_locations[DEFAULT_PICKUP]
      end

      # Since this component is used both on the record page and the ILL form, we need to know the right pickup value
      # to include so the right fulfillment endpoint is used.
      # @return [Symbol]
      def delivery_value
        @ill ? Fulfillment::Options::Deliverable::ILL_PICKUP : Fulfillment::Options::Deliverable::PICKUP
      end

      # If the options for the item include a scan or office option, don't check the pickup option
      # Otherwise, check the pickup option. See DeliverableComponent#pickup_checked? for similar logic.
      # @return [Hash, NilClass]
      def checked?
        %i[scan office].any? { |option| options.include?(option) } ? nil : { checked: true }
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
