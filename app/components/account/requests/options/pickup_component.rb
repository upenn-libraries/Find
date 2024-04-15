# frozen_string_literal: true

module Account
  module Requests
    module Options
      # pickup component logic
      class PickupComponent < ViewComponent::Base

        attr_accessor :facex, :default_pickup_location

        def initialize(facex:, default_pickup_location:)
          @facex = facex
          @default_pickup_location = default_pickup_location
        end

        def checked?
          facex ? nil : { checked: true }
        end
      end
    end
  end
end
