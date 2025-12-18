# frozen_string_literal: true

module Fulfillment
  module Choices
    # Wharton DocDel component logic
    class DocdelComponent < ViewComponent::Base
      attr_accessor :user, :checked, :radio_options, :holding_id

      def initialize(user:, checked: false, holding_id: nil, **radio_options)
        @user = user
        @checked = checked
        @holding_id = holding_id
        @radio_options = radio_options
      end

      def delivery_value
        Fulfillment::Options::Deliverable::DOCDEL
      end

      def radio_id
        holding_id ? "delivery_#{delivery_value}_#{holding_id}" : "delivery_#{delivery_value}"
      end
    end
  end
end
