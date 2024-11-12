# frozen_string_literal: true

module Fulfillment
  # Renders the circulation options for physical holdings
  class OptionsComponent < ViewComponent::Base
    include Turbo::FramesHelper

    attr_accessor :options, :options_set

    delegate :user, :item, :deliverable?, :unavailable?, :restricted?, to: :options_set

    # @param options_set [Fulfillment::OptionsSet]
    def initialize(options_set:)
      @options_set = options_set
      @options = options_set.to_a.inquiry
    end

    # Returns true if the request accepts a comment field.
    # @return [TrueClass, FalseClass]
    def commentable?
      options.any?(Fulfillment::Options::Deliverable::PICKUP,
                   Fulfillment::Options::Deliverable::ILL_PICKUP,
                   Fulfillment::Options::Deliverable::MAIL,
                   Fulfillment::Options::Deliverable::OFFICE)
    end

    # Generates the submit button for the given delivery type.
    # @param delivery_type [Symbol]
    # @return [ActiveSupport::SafeBuffer]
    def submit_button_for(delivery_type)
      submit_tag t(delivery_type, scope: 'requests.form.buttons'),
                 class: 'd-none btn btn-success btn-lg',
                 data: { request_options_target: "#{delivery_type}Button", turbo_frame: '_top' }
    end

    # Generates the electronic delivery link (scan request)
    # @return [ActiveSupport::SafeBuffer]
    def electronic_delivery_link
      link_to t('requests.form.buttons.scan'),
              ill_new_request_path(**item.scan_params),
              class: 'd-none btn btn-success btn-lg', target: '_blank', rel: 'noopener',
              data: { request_options_target: 'electronicButton', turbo_frame: '_top' }
    end
  end
end
