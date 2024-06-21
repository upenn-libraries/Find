# frozen_string_literal: true

module Account
  module Requests
    # renders the circulation options for physical holdings
    class OptionsComponent < ViewComponent::Base
      include Turbo::FramesHelper

      attr_accessor :item, :user, :options

      def initialize(user:, item:, options:)
        @user = user
        @item = item
        @options = options.inquiry
      end

      # Returns true if at least one delivery option is available.
      def deliverable?
        options.any?(Fulfillment::Request::Options::ELECTRONIC,
                     Fulfillment::Request::Options::PICKUP,
                     Fulfillment::Request::Options::MAIL,
                     Fulfillment::Request::Options::OFFICE)
      end

      def submit_button_for(delivery_type)
        submit_tag t(delivery_type, scope: 'requests.form.buttons'),
                   { class: 'd-none btn btn-success btn-lg',
                     data: { options_select_target: "#{delivery_type}Button", turbo_frame: '_top' } }
      end

      def electronic_delivery_link
        link_to t('requests.form.buttons.scan'),
                ill_new_request_path(**item.fulfillment_submission_params),
                { class: 'd-none btn btn-success btn-lg',
                  data: { options_select_target: 'electronicButton', turbo_frame: '_top' } }
      end

      def unavailable_link
        link_to t('requests.form.buttons.unavailable'),
                ill_new_request_path(**item.fulfillment_submission_params, requesttype: 'book'),
                { class: 'd-none btn btn-success btn-lg',
                  data: { options_select_target: 'unavailableButton', turbo_frame: '_top' } }
      end
    end
  end
end
