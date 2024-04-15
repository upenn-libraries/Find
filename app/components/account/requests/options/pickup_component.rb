# frozen_string_literal: true

module Account
  module Requests
    module Options
      # pickup component logic
      class PickupComponent < ViewComponent::Base

        def initialize(facex:, default_pickup_location:)
          @facex = facex
          @default_pickup_location = default_pickup_location
        end
      end
    end
  end
end
