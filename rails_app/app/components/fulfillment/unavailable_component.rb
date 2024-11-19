# frozen_string_literal: true

module Fulfillment
  # Unavailable component logic
  class UnavailableComponent < ViewComponent::Base
    attr_accessor :options

    delegate :item, :user, to: :options

    def initialize(options_set:)
      @options = options_set
    end

    # @return [ActiveSupport::SafeBuffer]
    def ill_request_link
      link_to t('requests.form.ill_request_link'),
              ill_new_request_path(**item.loan_params),
              class: 'btn btn-success btn-lg', target: '_blank', rel: 'noopener'
    end
  end
end
