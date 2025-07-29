# frozen_string_literal: true

module Fulfillment
  # Deliverable component logic
  class DeliverableComponent < ViewComponent::Base
    attr_accessor :options

    delegate :item, :user, to: :options

    # @param options_set [OptionsSet]
    def initialize(options_set:)
      @options = options_set
    end

    # Returns true if the request accepts a comment field.
    # @return [Boolean]
    def commentable?
      options.inquiry.any?(Fulfillment::Options::Deliverable::ILL_PICKUP,
                           Fulfillment::Options::Deliverable::PICKUP,
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
              class: 'd-none btn btn-success btn-lg', target: '_blank', rel: :noopener,
              data: { request_options_target: 'electronicButton', turbo_frame: '_top' }
    end

    # Determine if the pickup options should default to being checked. The pickup option should be checked only if no
    # electronic or office delivery option is shown. See PickupComponent#checked? for similar logic.
    # @return [Boolean]
    def pickup_checked?
      (options.to_a & [Options::Deliverable::ELECTRONIC, Options::Deliverable::OFFICE]).empty?
    end
  end
end
