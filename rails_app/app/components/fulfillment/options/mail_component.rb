# frozen_string_literal: true

module Fulfillment
  module Options
    # Mail delivery component
    class MailComponent < ViewComponent::Base
      attr_accessor :user, :checked, :radio_options

      def initialize(user:, checked: false, **radio_options)
        @user = user
        @checked = checked
        @radio_options = radio_options
      end

      def delivery_value
        Fulfillment::Request::Options::MAIL
      end

      # @return [Array<String>, nil]
      def bbm_address
        @bbm_address ||= user.bbm_delivery_address
      end
    end
  end
end
