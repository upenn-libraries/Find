# frozen_string_literal: true

module Account
  module Requests
    module Options
      # pickup component logic
      class PickupComponent < ViewComponent::Base

        attr_accessor :default_pickup_location, :options

        def initialize(default_pickup_location:, options:)
          @default_pickup_location = default_pickup_location
          @options = options
        end

        def checked?
          options.include? :office ? nil : { checked: true }
        end
      end
    end
  end
end
