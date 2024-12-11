# frozen_string_literal: true

module Fulfillment
  module Choices
    # office delivery component logic
    class OfficeComponent < ViewComponent::Base
      attr_accessor :user, :checked, :radio_options

      def initialize(user:, checked: false, **radio_options)
        @user = user
        @checked = checked
        @radio_options = radio_options
      end

      def delivery_value
        Fulfillment::Options::Deliverable::OFFICE
      end

      # @return [Array<String>, nil]
      def office_address
        @office_address ||= user.office_delivery_address
      end
    end
  end
end
