# frozen_string_literal: true

module Inventory
  module Full
    module Entry
      # Reusable CTA button for navigating to an online resource.
      class OnlineCtaComponent < ViewComponent::Base
        attr_reader :href

        # @param href [String]
        def initialize(href:)
          @href = href
        end
      end
    end
  end
end
