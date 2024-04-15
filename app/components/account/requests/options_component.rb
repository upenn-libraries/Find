# frozen_string_literal: true

module Account
  module Requests
    # renders the circulation options for physical holdings
    class OptionsComponent < ViewComponent::Base
      include Turbo::FramesHelper

      FACULTY_EXPRESS_CODE = 'FacEXP'
      STUDENT_GROUP_CODES = %w[undergrad graduate].freeze
      DEFAULT_STUDENT_PICKUP = 'VPLOCKER'
      DEFAULT_PICKUP = 'VanPeltLib'

      attr_accessor :item, :user

      def initialize(item:, user:)
        @item = item
        @user = user
      end

      def default_pickup_location
        return DEFAULT_STUDENT_PICKUP if user_is_student?

        DEFAULT_PICKUP
      end

      def user_address
        return unless user_is_facex?

        Illiad::User.find(id: user.uid).address
      end

      def user_is_student?
        STUDENT_GROUP_CODES.include? user.ils_group
      end

      def user_is_facex?
        user.ils_group == FACULTY_EXPRESS_CODE
      end
    end
  end
end
