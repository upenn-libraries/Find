# frozen_string_literal: true

module Fulfillment
  # Renders the circulation options for physical holdings
  class OptionsComponent < ViewComponent::Base
    include Turbo::FramesHelper

    attr_accessor :options

    delegate :user, :item, :any?, :deliverable?, :unavailable?, :restricted?, to: :options

    # @param options_set [Fulfillment::OptionsSet]
    def initialize(options_set:)
      @options = options_set
    end

    # Returns true if the request accepts a comment field.
    # @return [TrueClass, FalseClass]
    def commentable?
      options.inquiry.any?(Fulfillment::Options::Deliverable::PICKUP,
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

    # Determine if the pickup options should default to being checked
    # @return [Boolean]
    def pickup_checked?
      options.inquiry.any? Options::Deliverable::ELECTRONIC, Options::Deliverable::OFFICE
    end
  end
end
