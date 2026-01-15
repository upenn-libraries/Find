# frozen_string_literal: true

module Fulfillment
  module Choices
    # Base functionality shared across Fulfillment::Choices components
    class BaseComponent < ViewComponent::Base
      attr_accessor :user, :checked, :radio_options, :holding_id

      def initialize(user:, ill: false, checked: false, holding_id: nil, **radio_options)
        @user = user
        @checked = checked
        @ill = ill
        @holding_id = holding_id
        @radio_options = radio_options
      end

      # The text for display next to the radio button
      def radio_label_content
        raise NotImplementedError
      end

      def radio_input_label
        label_tag radio_id, radio_label_content,
                  class: 'form-check-label'
      end

      def radio_input_element
        radio_button_tag :delivery,
                         delivery_value,
                         checked, id: radio_id, class: 'form-check-input',
                                  data: { action: 'change->request-options#optionChanged' }
      end

      private

      def radio_id
        holding_id ? "delivery_#{delivery_value}_#{holding_id}" : "delivery_#{delivery_value}"
      end
    end
  end
end
