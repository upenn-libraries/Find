# frozen_string_literal: true

module Account
  module Requests
    module Options
      # office delivery component logic
      class OfficeComponent < ViewComponent::Base
        attr_accessor :user, :checked, :radio_options

        def initialize(user:, checked: false, **radio_options)
          @user = user
          @checked = checked
          @radio_options = radio_options
          @name = Fulfillment::Request::Options::OFFICE_DELIVERY
        end

        # @return [Array<String>, nil]
        def user_address
          @user_address ||= user.illiad_record.bbm_delivery_address
        end

        def user_address?
          user_address.compact_blank.present?
        end
      end
    end
  end
end
