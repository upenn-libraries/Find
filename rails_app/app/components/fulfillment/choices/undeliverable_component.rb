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

      def ill_request_link
        link_to 'Request this Item via InterLibrary Loan',
                ill_new_request_path(**item.loan_params),
                class: 'btn btn-success btn-lg', target: '_blank', rel: 'noopener'
      end
    end
  end
end
