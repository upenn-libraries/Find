# frozen_string_literal: true

module Fulfillment
  module Choices
    # Undeliverable component logic
    class UndeliverableComponent < ViewComponent::Base
      attr_accessor :options

      delegate :item, :unavailable?, :restricted?, to: :options

      def initialize(options_set:)
        @options = options_set
      end

      def ill_request_link
        link_to t('requests.form.ill_request_link'),
                ill_new_request_path(**item.loan_params),
                class: 'btn btn-success btn-lg', target: '_blank', rel: 'noopener'
      end
    end
  end
end
