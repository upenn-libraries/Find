# frozen_string_literal: true

module Account
  module Requests
    module Options
      # office delivery component logic
      class OfficeComponent < ViewComponent::Base
        attr_accessor :user_address, :options

        def initialize(user_address:, options:)
          @user_address = user_address
          @options = options
        end

        def user_address_set?
          user_address.compact_blank.present?
        end

        def checked?
          options.include?(:scan) ? nil : { checked: true }
        end
      end
    end
  end
end
