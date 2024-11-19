# frozen_string_literal: true

module Fulfillment
  # Undeliverable component logic
  class UndeliverableComponent < ViewComponent::Base
    attr_accessor :options

    delegate :item, :unavailable?, :restricted?, to: :options

    def initialize(options_set:)
      @options = options_set
    end

    # @return [ActiveSupport::SafeBuffer]
    def aeon_request_link
      link_to t('requests.form.buttons.aeon'),
              Settings.aeon.requesting_url + item.aeon_params.to_query,
              class: 'btn btn-success btn-lg',
              data: { turbo_frame: '_top' }
    end

    # @return [ActiveSupport::SafeBuffer]
    def hsp_link
      link_to t('requests.form.buttons.hsp'), t('urls.requesting_info.hsp_appointment'),
              class: 'btn btn-success btn-lg', target: '_blank', rel: 'noopener'
    end
  end
end
