# frozen_string_literal: true

module Account
  module Requests
    module Options
      # Pickup component logic
      class PickupComponent < ViewComponent::Base
        DEFAULT_STUDENT_PICKUP = 'VPLOCKER'
        DEFAULT_PICKUP = 'VanPeltLib'

        attr_accessor :user, :checked, :radio_options

        def initialize(user:, ill: false, checked: false, **radio_options)
          @user = user
          @checked = checked
          @ill = ill
          @radio_options = radio_options
        end

        # @return [String]
        def default_pickup_location
          return DEFAULT_STUDENT_PICKUP if user.student?

          DEFAULT_PICKUP
        end

        def delivery_value
          @ill ? Fulfillment::Request::Options::ILL_PICKUP : Fulfillment::Request::Options::PICKUP
        end

        # If the options for the item include a scan or office option, don't check the pickup option
        # Otherwise, check the pickup option
        # @return [Hash, NilClass]
        def checked?
          %i[scan office].any? { |option| options.include?(option) } ? nil : { checked: true }
        end
      end
    end
  end
end
