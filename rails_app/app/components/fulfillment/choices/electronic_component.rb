# frozen_string_literal: true

module Fulfillment
  module Choices
    # Electronic delivery component
    class ElectronicComponent < ViewComponent::Base
      attr_accessor :checked, :radio_options, :holding_id

      def initialize(checked: false, holding_id: nil, **radio_options)
        @checked = checked
        @holding_id = holding_id
        @radio_options = radio_options
      end

      def delivery_value
        Fulfillment::Options::Deliverable::ELECTRONIC
      end

      def radio_id
        holding_id ? "delivery_#{delivery_value}_#{holding_id}" : "delivery_#{delivery_value}"
      end
    end
  end
end
