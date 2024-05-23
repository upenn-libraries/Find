# frozen_string_literal: true

module Account
  module Requests
    # renders the circulation options for physical holdings
    class OptionsComponent < ViewComponent::Base
      include Turbo::FramesHelper

      DEFAULT_STUDENT_PICKUP = 'VPLOCKER'
      DEFAULT_PICKUP = 'VanPeltLib'

      attr_accessor :item, :user, :options

      def initialize(user:, options:)
        @user = user
        @options = options
      end

      # @return [String]
      def default_pickup_location
        return DEFAULT_STUDENT_PICKUP if user.student?

        DEFAULT_PICKUP
      end

      # @return [Array<String>, nil]
      def user_address
        return unless options.include? :office

        Illiad::User.find(id: user.uid).bbm_delivery_address
      end
    end
  end
end
