# frozen_string_literal: true

module Fulfillment
  module Choices
    # Undeliverable component logic
    class UndeliverableComponent < ViewComponent::Base
      attr_accessor :options, :options_set

      delegate :item, :unavailable?, :restricted?, to: :options_set

      def initialize(options_set:)
        @options_set = options_set
        @options = options_set.to_a.inquiry
      end
    end
  end
end
