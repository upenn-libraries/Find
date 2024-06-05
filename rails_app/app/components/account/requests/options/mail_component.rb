# frozen_string_literal: true

module Account
  module Requests
    module Options
      # Mail delivery component
      class MailComponent < ViewComponent::Base
        attr_accessor :checked, :radio_options

        def initialize(checked: false, **radio_options)
          @checked = checked
          @radio_options = radio_options
          @name = Fulfillment::Request::Options::HOME_DELIVERY
        end
      end
    end
  end
end
