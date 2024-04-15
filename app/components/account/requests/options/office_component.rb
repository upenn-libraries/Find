# frozen_string_literal: true

module Account
  module Requests
    module Options
      # office delivery component logic
      class OfficeComponent < ViewComponent::Base

        def initialize(user_address:)
          @user_address = user_address
        end

        def user_address_set?
          @user_address.compact_blank.present?
        end
      end
    end
  end
end
