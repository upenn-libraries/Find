# frozen_string_literal: true

module Account
  module Requests
    # renders the circulation options for physical holdings
    class OptionsComponent < ViewComponent::Base
      attr_accessor :form

      DEFAULT_PICKUP = 'VanPeltLib'
      DEFAULT_STUDENT_PICKUP = 'VPLOCKER'

      def initialize(alma_user:, form:)
        @alma_user = alma_user
        @form = form
      end

      def default_pickup_location
        return DEFAULT_STUDENT_PICKUP if user_is_student?

        DEFAULT_PICKUP
      end

      def user_address
        return unless user_is_facex?

        Illiad::User.find(id: user_id).address
      end

      def user_is_student?
        @alma_user.user_group['desc'].include? 'Student'
      end

      def user_is_facex?
        @alma_user.user_group['desc'] == 'Faculty Express'
      end

      private

      def user_id
        @alma_user.user_identifier.first['value']
      end
    end
  end
end
