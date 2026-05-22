# frozen_string_literal: true

module Fulfillment
  # Deliverable component logic
  class DeliverableComponent < ViewComponent::Base
    attr_accessor :options, :preselected_option

    delegate :item, :user, to: :options

    # @param options_set [OptionsSet]
    def initialize(options_set:)
      @options = options_set
      @preselected_option = determine_preselected_option
    end

    # Returns true if the request accepts a comment field.
    # @return [Boolean]
    def commentable?
      options.inquiry.any?(Fulfillment::Options::Deliverable::ILL_PICKUP,
                           Fulfillment::Options::Deliverable::PICKUP,
                           Fulfillment::Options::Deliverable::MAIL,
                           Fulfillment::Options::Deliverable::OFFICE,
                           Fulfillment::Options::Deliverable::DOCDEL)
    end

    # Helper to determine if an option should be preselected. See #determine_preselected_option for logic.
    # @param delivery_option [Object]
    # @return [Boolean]
    def preselect?(delivery_option)
      delivery_option == preselected_option
    end

    # Generate class name for a given option, which must follow the naming convention corresponding to the constant's
    # symbol value.
    # @param option [Symbol]
    # @return [Class] corresponding view component class
    def component_class_for(option:)
      raise ArgumentError unless Options::Deliverable.all.include? option

      "Fulfillment::Choices::#{option.to_s.camelize}Component".safe_constantize
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

    private

    def determine_preselected_option
      return Options::Deliverable::DOCDEL if options.inquiry.docdel?

      return Options::Deliverable::OFFICE if options.inquiry.office?

      return Options::Deliverable::ELECTRONIC if options.inquiry.electronic?

      Options::Deliverable::PICKUP
    end
  end
end
