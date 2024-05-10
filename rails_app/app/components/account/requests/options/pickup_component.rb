# frozen_string_literal: true

module Account
  module Requests
    module Options
      # Pickup component logic
      class PickupComponent < ViewComponent::Base
        attr_accessor :default_pickup_location, :options

        def initialize(default_pickup_location:, options:)
          @default_pickup_location = default_pickup_location
          @options = options
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
