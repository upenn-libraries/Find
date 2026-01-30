# frozen_string_literal: true

module Fulfillment
  module Choices
    # Pickup option radio button
    class RadioButtonComponent < ViewComponent::Base
      attr_accessor :checked, :delivery_value, :holding_id

      # @param [Boolean] checked
      # @param [String] holding_id
      # @param [Symbol] delivery_value
      def initialize(checked:, holding_id:, delivery_value:)
        @checked = checked
        @holding_id = holding_id
        @delivery_value = delivery_value
      end

      def call
        radio_button_tag(:delivery, delivery_value,
                         checked, id: radio_id, class: 'form-check-input',
                                  data: { action: 'change->request-options#optionChanged' }) +
          label_tag(radio_id, label_text, class: 'form-check-label')
      end

      private

      # @return [String]
      def label_text
        t("requests.form.options.#{delivery_value}.label")
      end

      # @return [String]
      def radio_id
        holding_id ? "delivery_#{delivery_value}_#{holding_id}" : "delivery_#{delivery_value}"
      end
    end
  end
end
