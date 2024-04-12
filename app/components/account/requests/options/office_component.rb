# frozen_string_literal: true

module Account
  module Requests
    module Options
      # office delivery component logic
      class OfficeComponent < ViewComponent::Base
        attr_accessor :form

        def initialize(user_address:, form:)
          @user_address = user_address
          @form = form
        end

        def user_address_set?
          @user_address.compact_blank.present?
        end
      end
    end
  end
end
