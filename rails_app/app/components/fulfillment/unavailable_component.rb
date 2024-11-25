# frozen_string_literal: true

module Fulfillment
  # Renders options available to user when a item is unavailable. When an item is unavailable Penn users can submit ILL
  # requests, while courtesy borrowers cannot.
  class UnavailableComponent < ViewComponent::Base
    attr_accessor :options

    delegate :item, :user, to: :options

    # @param [Fulfillment::OptionsSet] options_set
    def initialize(options_set:)
      @options = options_set
    end

    # @return [Boolean, nil]
    def user_is_courtesy_borrower?
      user&.courtesy_borrower?
    end

    # @return [String]
    def message
      user_is_courtesy_borrower? ? t('requests.form.options.none.info') : t('requests.form.options.ill.info')
    end

    # @return [ActiveSupport::SafeBuffer]
    def ill_request_link
      link_to t('requests.form.ill_request_link'),
              ill_new_request_path(**item.loan_params),
              class: 'btn btn-success btn-lg', target: '_blank', rel: 'noopener'
    end
  end
end
