# frozen_string_literal: true

module Account
  module Requests
    # renders the circulation options for physical holdings
    class OptionsComponent < ViewComponent::Base
      include Turbo::FramesHelper

      STUDENT_GROUP_CODES = %w[undergrad graduate GIC].freeze
      DEFAULT_STUDENT_PICKUP = 'VPLOCKER'
      DEFAULT_PICKUP = 'VanPeltLib'

      attr_accessor :item, :user, :options

      def initialize(user:, options:)
        @user = user
        @options = options
      end

      # @return [String]
      def default_pickup_location
        return DEFAULT_STUDENT_PICKUP if user_is_student?

        DEFAULT_PICKUP
      end

      # @return [Array<String>, nil]
      def user_address
        return unless options.include? :office

        Illiad::User.find(id: user.uid).bbm_delivery_address
      end

      # @return [TrueClass, FalseClass]
      def user_is_student?
        STUDENT_GROUP_CODES.include? user.alma_group.value
      end
    end
  end
end
