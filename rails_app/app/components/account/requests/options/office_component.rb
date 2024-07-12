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
        end

        def delivery_value
          Fulfillment::Request::Options::OFFICE
        end

        # @return [Array<String>, nil]
        def user_address
          return unless user.illiad_record

          @user_address ||= user.illiad_record.bbm_delivery_address
        end

        def user_address?
          user_address&.compact_blank.present?
        end
      end
    end
  end
end
