# frozen_string_literal: true

module Account
  module Requests
    module Options
      # pickup component logic
      class PickupComponent < ViewComponent::Base
        attr_accessor :form

        def initialize(facex:, default_pickup_location:, form:)
          @facex = facex
          @default_pickup_location = default_pickup_location
          @form = form
        end
      end
    end
  end
end
