# frozen_string_literal: true

module Fulfillment
  module Choices
    # office delivery component logic
    class OfficeComponent < BaseComponent
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
