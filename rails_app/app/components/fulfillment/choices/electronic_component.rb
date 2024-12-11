# frozen_string_literal: true

module Fulfillment
  module Choices
    # Mail delivery component
    class ElectronicComponent < ViewComponent::Base
      attr_accessor :checked, :radio_options

      def initialize(checked: false, **radio_options)
        @checked = checked
        @radio_options = radio_options
      end

      def delivery_value
        Fulfillment::Options::Deliverable::ELECTRONIC
      end
    end
  end
end
