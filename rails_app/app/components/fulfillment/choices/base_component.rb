# frozen_string_literal: true

module Fulfillment
  module Choices
    # Base functionality shared across Fulfillment::Choices components
    class BaseComponent < ViewComponent::Base
      attr_accessor :user, :checked, :holding_id

      renders_one :radio_button_component

      # @param [User] user
      # @param [Boolean] checked
      # @param [String, nil] holding_id
      def initialize(user:, checked: false, holding_id: nil)
        @user = user
        @checked = checked
        @holding_id = holding_id
      end

      # Subclasses must implement a Symbol value here, coming from Fulfillment::Options
      def delivery_value
        raise NotImplementedError
      end

      # Value for radio_button_component slot, rendered by subclass templates
      def default_radio_button_component
        Fulfillment::Choices::RadioButtonComponent.new(
          checked: checked, holding_id: holding_id, delivery_value: delivery_value
        )
      end

      private

      def generate_pickup_locations(type)
        locations = Settings.locations.pickup.to_h
        locations.transform_keys(&:to_s) # Transform keys to strings
                 .transform_values { |v| v[type] } # Retrieve :ils or :ill location values
                 .reject { |_, v| v.blank? } # Remove any locations that don't have codes
      end
    end
  end
end
