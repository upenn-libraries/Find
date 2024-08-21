# frozen_string_literal: true

module Fulfillment
  module Options
    # Mail delivery component
    class ElectronicComponent < ViewComponent::Base
      attr_accessor :checked, :radio_options

      def initialize(checked: false, **radio_options)
        @checked = checked
        @radio_options = radio_options
      end

      def delivery_value
        Fulfillment::Request::Options::ELECTRONIC
      end
    end
  end
end
