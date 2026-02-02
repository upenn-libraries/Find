# frozen_string_literal: true

module Fulfillment
  module Choices
    # Mail delivery component
    class MailComponent < BaseComponent
      def delivery_value
        Fulfillment::Options::Deliverable::MAIL
      end

      # @return [Array<String>, nil]
      def bbm_address
        @bbm_address ||= user.bbm_delivery_address
      end
    end
  end
end
