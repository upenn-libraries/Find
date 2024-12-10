# frozen_string_literal: true

module Fulfillment
  # Renders options (or lack thereof) available to user when a item is unavailable. Not much going on here for now.
  # Logically, only courtesy borrowers should land here when a circulating item is unavailable.
  class UnavailableComponent < ViewComponent::Base
    attr_accessor :options

    delegate :item, :user, to: :options

    # @param [Fulfillment::OptionsSet] options_set
    def initialize(options_set:)
      @options = options_set
    end
  end
end
