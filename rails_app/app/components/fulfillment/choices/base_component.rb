# frozen_string_literal: true

module Fulfillment
  module Choices
    # Base functionality shared across Fulfillment::Choices components
    class BaseComponent < ViewComponent::Base
      attr_accessor :user, :checked, :holding_id

      def initialize(user:, ill: false, checked: false, holding_id: nil)
        @user = user
        @checked = checked
        @ill = ill
        @holding_id = holding_id
      end

      def radio_button_component
        Fulfillment::Choices::RadioButtonComponent.new(
          checked: checked, holding_id: holding_id, delivery_value: delivery_value
        )
      end
    end
  end
end
