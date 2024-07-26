# frozen_string_literal: true

module Account
  module Requests
    # Renders the circulation options for physical holdings
    class OptionsComponent < ViewComponent::Base
      include Turbo::FramesHelper

      attr_accessor :item, :user, :options

      def initialize(user:, item:)
        @user = user
        @item = item
        @options = item.fulfillment_options(ils_group: user.ils_group).inquiry
      end

      # Returns true if at least one delivery option is available.
      def deliverable?
        options.any?(Fulfillment::Request::Options::ELECTRONIC,
                     Fulfillment::Request::Options::PICKUP,
                     Fulfillment::Request::Options::MAIL,
                     Fulfillment::Request::Options::OFFICE)
      end

      # Returns true if the request accepts a comment field.
      # @return [TrueClass, FalseClass]
      def commentable?
        options.any?(Fulfillment::Request::Options::PICKUP,
                     Fulfillment::Request::Options::ILL_PICKUP,
                     Fulfillment::Request::Options::MAIL,
                     Fulfillment::Request::Options::OFFICE)
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

      # Generates the Aeon request link with open parameters for form pre-population.
      # @return [ActiveSupport::SafeBuffer]
      def aeon_link
        link_to t('requests.form.buttons.aeon'),
                Settings.aeon.requesting_url + item.aeon_params.to_query,
                class: 'btn btn-success btn-lg',
                data: { turbo_frame: '_top' }
      end
    end
  end
end
